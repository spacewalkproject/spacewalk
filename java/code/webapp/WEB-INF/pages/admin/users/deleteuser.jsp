<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="fa-user" imgAlt="users.jsp.imgAlt">
            <c:out escapeXml="true" value="${targetuser.login}" />
        </rhn:toolbar>
        <form method="POST" action="/rhn/users/DeleteUserSubmit.do?uid=${param.uid}">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2><bean:message key="deleteuser.jsp.confirm"/></h2>
                </div>
                <div class="panel-body">
                    <p><bean:message key="deleteuser.jsp.body"/></p>
                    <p>
                        <rhn:csrf />
                        <html:submit styleClass="btn btn-danger">
                            <bean:message key="deleteuser.jsp.delete"/>
                        </html:submit>
                    </p>
                </div>
            </div>
        </form>
    </body>
</html>
