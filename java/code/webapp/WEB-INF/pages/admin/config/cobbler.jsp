<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >

<body>
    <rhn:toolbar base="h1" icon="header-info" imgAlt="info.alt.img">
      <bean:message key="cobbler.jsp.toolbar"/>
    </rhn:toolbar>
    <p>
        <bean:message key="cobbler.jsp.summary1"/>
    </p>
    <p>
        <bean:message key="cobbler.jsp.summary2"/>
    </p>
    <p>
        <bean:message key="cobbler.jsp.summary3"/>
    </p>
    <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4><bean:message key="cobbler.jsp.header2"/></h4>
        </div>
        <div class="panel-body">
            <form action="/rhn/admin/config/Cobbler.do" method="POST">
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="cobbler.jsp.sync"/>
                    </label>
                    <div class="col-lg-6">
                        <input type="submit" class="btn btn-default" name="cobbler_sync" value="${rhn:localize('update')}" />
                        <rhn:csrf />
                        <rhn:submitted/>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html:html>

