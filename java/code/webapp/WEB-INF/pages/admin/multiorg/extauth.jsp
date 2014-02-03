<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
    <body>
    <rhn:toolbar base="h1" icon="header-organisation"
                 miscUrl="${url}"
                 miscAcl="user_role(sat_admin)"
                 miscText="${text}"
                 miscImg="${img}"
                 miscAlt="${text}"
                 imgAlt="users.jsp.imgAlt">
        <bean:message key="org.allusers.title1" />
    </rhn:toolbar>

    <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/admin_user.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <p>
    <bean:message key="extauth.org.message"/>
  </p>

  <html:form method="post" action="/admin/multiorg/ExternalAuthentication.do" styleClass="form-horizontal">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h2><bean:message key="extauth.user.create"/></h2>
      </div>
      <div class="panel-body">
        <rhn:csrf />
        <html:hidden property="submitted" value="true"/>
        <div class="form-group">
          <div class="col-md-3 control-label">
            <bean:message key="extauth.org.useou"/>
          </div>
          <div class="col-md-4">
            <div class="checkbox">
              <html:checkbox property="use_ou"/>
           </div>
          </div>
        </div>
        <div class="form-group">
          <div class="col-md-3 control-label">
            <bean:message key="extauth.org.default"/>
          </div>
          <div class="col-md-4">
            <html:select property="to_org" styleClass="form-control">
              <html:options collection="orgs"
                property="value" labelProperty="label" />
            </html:select>
            <span class="help-block">
              <bean:message key="extauth.org.default.help" />
            </span>
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
