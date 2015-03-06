<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
    <head>
        <script src="/ace-editor/ace.js"></script>
    </head>
    <body>
        <rhn:require acl="user_role(satellite_admin)"/>
        <rhn:toolbar base="h1" icon="header-list">Tomcat</rhn:toolbar>
        <form action="/rhn/admin/Catalina.do">
            <rhn:csrf />
            <div class="panel panel-default">
                <div class="panel-heading">
                    <c:out value="${logfile_path}"/>
                </div>
                <div class="panel-body">
                    <textarea data-editor="text" data-readonly="true" rows="24" class="form-control">${contents}</textarea>
                </div>
            </div>
            <rhn:submitted/>
        </form>
    </body>
</html>
