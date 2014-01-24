<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
  <rhn:toolbar base="h1" icon="header-channel-mapping" iconAlt="info.alt.img">
    <bean:message key="extgroup.jsp.delete" arg0="${group.label}"/>
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/admin_user.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <div class="page-summary">
    <p><bean:message key="extgroup.jsp.delete.summary"/></p>
  </div>

  <html:form method="post" action="/admin/multiorg/ExtGroupDelete.do?gid=${gid}" styleClass="form-horizontal">
    <rhn:csrf />
    <rhn:submitted/>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h2><bean:message key="extgroup.jsp.header"/></h2>
      </div>
      <div class="panel-body">
        <div class="form-group">
          <label class="col-lg-3 control-label">
            <bean:message key="extgrouplist.jsp.name"/>
          </label>
          <div class="col-lg-6">
            <c:out value="${group.label}" />
          </div>
        </div>
        <div class="form-group">
          <label class="col-lg-3 control-label">
            <bean:message key="userdetails.jsp.roles"/>
          </label>
          <div class="col-lg-6">
            <c:out value="${group.roleNames}" />
          </div>
        </div>
      </div>
    </div>

    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-6">
        <html:submit><bean:message key="extgroup.jsp.delete"/></html:submit>
        <html:hidden property="gid" value="${gid}" />
      </div>
    </div>
  </html:form>

</body>
</html:html>
