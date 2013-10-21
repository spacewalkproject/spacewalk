<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">

<body>
    <rhn:toolbar base="h1" icon="icon-info-sign" imgAlt="info.alt.img">
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
                <rhn:csrf />
                <table class="table">
                <tr>
                    <th>
                        <bean:message key="cobbler.jsp.sync"/>
                    </th>
                    <td>
                        <input type="submit" class="btn btn-success" name="cobbler_sync" value="${rhn:localize('update')}" />
                    </td>
                </tr>
                </table>
                <hr/>
            <rhn:submitted/>
            </form>
        </div>
    </div>
</body>
</html:html>

