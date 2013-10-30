<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="fa-user" imgAlt="users.jsp.imgAlt">
            <c:out escapeXml="true" value="${targetuser.login}" />
        </rhn:toolbar>
        <form method="POST" action="/rhn/users/DisableUserSubmit.do?uid=${param.uid}">
            <div class="jumbotron">
                <div class="container">
                    <h2><bean:message key="disableuser.jsp.confirm"/></h2>
                    <p><bean:message key="disableuser.jsp.body"/></p>
                    <br/>
                    <rhn:csrf />
                    <html:submit styleClass="btn btn-danger btn-lg">
                        <bean:message key="disableuser.jsp.disable"/>
                    </html:submit>
                </div>
            </div>
        </form>
    </body>
</html>
