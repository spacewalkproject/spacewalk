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
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2><bean:message key="enableuser.jsp.confirm"/></h2>
                </div>
                <div class="panel-body">
                    <p><bean:message key="enableuser.jsp.body"/></p>
                    <rhn:csrf />
                    <br/>
                    <p>
                        <html:submit styleClass="btn btn-success">
                            <bean:message key="enableuser.jsp.enable"/>
                        </html:submit>
                    </p>
                </div>
            </div>
        </form>
    </body>
</html>
