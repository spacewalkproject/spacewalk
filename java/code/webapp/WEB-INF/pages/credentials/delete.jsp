<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="header-user" imgAlt="users.jsp.imgAlt"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account">
            <bean:message key="credentials.jsp.delete.dispatch" />
        </rhn:toolbar>
        <p><bean:message key="credentials.jsp.delete.summary" /></p>

        <form method="post" action="/rhn/account/DeleteCredentials.do">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2><bean:message key="credentials.jsp.susestudio" /></h2>
                </div>
                <div class="panel-body">
                    <div class="row-0">
                        <div class="col-sm-2">
                            <bean:message key="credentials.jsp.username" />
                        </div>
                        <div class="col-sm-6">
                            <strong><c:out value="${creds.username}" /></strong>
                        </div>
                    </div>
                    <div class="row-0">
                        <div class="col-sm-2">
                            <bean:message key="credentials.jsp.apikey" />
                        </div>
                        <div class="col-sm-6">
                            <strong><c:out value="${creds.password}" /></strong>
                        </div>
                    </div>
                    <div class="row-0">
                        <div class="col-sm-2">
                            <strong>
                                <bean:message key="credentials.jsp.url" />
                            </strong>
                        </div>
                        <div class="col-sm-6">
                            <a href="${creds.url}">
                                <c:out value="${creds.url}" />
                            </a>
                        </div>
                    </div>
                    <rhn:csrf />
                    <rhn:submitted />
                    <hr/>
                    <html:submit property="dispatch" styleClass="btn btn-danger">
                        <bean:message key="credentials.jsp.delete.dispatch" />
                    </html:submit>
                </div>
            </div>
        </form>
    </body>
</html>
