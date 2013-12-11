<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="header-user" imgAlt="users.jsp.imgAlt">
            <bean:message key="disableself.jsp.account_deactivation" />
        </rhn:toolbar>
        <form method="post" name="rhn_list" action="/rhn/account/AccountDeactivationSubmit.do">
            <div class="panel panel-default">
                <div class="panel-body">
                    <p><bean:message key="disableself.jsp.message" /></p>
                    <rhn:csrf />
                    <p>
                        <html:submit styleClass="btn btn-danger">
                            <bean:message key="disableself.jsp.deactivate"/>
                        </html:submit>
                    </p>
                </div>
            </div>
        </form>
    </body>
</html>
