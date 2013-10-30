<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
    <head>
        <meta name="name" value="User Details" />
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
        <form method="POST" action="/rhn/users/EnableUserSubmit.do?uid=${param.uid}">
            <div class="jumbotron">
                <h2><bean:message key="enableuser.jsp.confirm"/></h2>
                <p><bean:message key="enableuser.jsp.body"/></p>
                <rhn:csrf />
                <br/>
                <p>
                    <html:submit styleClass="btn btn-success btn-lg">
                        <bean:message key="enableuser.jsp.enable"/>
                    </html:submit>
                </p>
            </div>
        </form>
    </body>
</html>
