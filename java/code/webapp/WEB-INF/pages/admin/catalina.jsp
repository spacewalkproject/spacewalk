<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <body>
        <rhn:require acl="user_role(satellite_admin)"/>
        <rhn:toolbar base="h1" icon="header-list">Tomcat</rhn:toolbar>
        <form action="/rhn/admin/Catalina.do">
            <rhn:csrf />
            <div class="panel panel-default">
                <div class="panel-heading">
                    <bean:message key="catalina.jsp.show"/>
                </div>
                <div class="panel-body">
                    <textarea readonly rows="24" class="form-control">${contents}</textarea>
                </div>
            </div>
            <rhn:submitted/>
        </form>
    </body>
</html>
