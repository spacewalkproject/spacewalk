<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="header-organisation">
            <bean:message key="orgdelete.jsp.header1" arg0="${orgName}"/>
        </rhn:toolbar>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/org_tabs.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <html:form action="/admin/multiorg/DeleteOrg?oid=${oid}">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4><bean:message key="orgdelete.jsp.header2"/></h4>
                </div>
                <div class="panel-body">
                    <table class="table">
                        <tr>
                            <td>
                                <bean:message key="org.name.jsp"/>
                            </td>
                            <td>
                                ${orgName}
                            </td>
                        </tr>
                        <tr>
                            <td><bean:message key="org.active.users.jsp"/></td>
                            <td>${users}</td>
                        </tr>
                        <tr>
                            <td>
                                <bean:message key="org.systems.jsp"/>
                            </td>
                            <td>
                                ${systems}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <bean:message key="org.system.groups.jsp"/>
                            </td>
                            <td>
                                ${groups}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <bean:message key="org.actkeys.jsp"/>
                            </td>
                            <td>
                                ${actkeys}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <bean:message key="org.kickstart.profiles.jsp"/>
                            </td>
                            <td>
                                ${ksprofiles}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <bean:message key="org.config.channels.jsp"/>
                            </td>
                            <td>
                                ${cfgchannels}
                            </td>
                        </tr>
                    </table>
                    <br/>
                    <html:submit styleClass="btn btn-danger">
                        <bean:message key="orgdelete.jsp.submit"/>
                    </html:submit>
                    <rhn:csrf />
                    <html:hidden property="submitted" value="true"/>
                </div>
            </div>
        </html:form>
    </body>
</html>
