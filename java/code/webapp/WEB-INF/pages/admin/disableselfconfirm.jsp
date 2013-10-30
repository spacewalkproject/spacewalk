<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="fa-user">
            <bean:message key="disableselfconfirm.jsp.warning_question" />
        </rhn:toolbar>
        <form method="POST" name="rhn_list" action="/rhn/account/AccountDeactivationConfirm.do">
            <div class="jumbotron">
                <div class="container">
                    <p><bean:message key="disableselfconfirm.jsp.warning" /></p>
                    <br/>
                    <html:submit styleClass="btn btn-danger btn-lg">
                        <bean:message key="disableself.jsp.deactivate"/>
                    </html:submit>
                    <html:hidden property="submitted" value="true" />
                    <rhn:csrf />
                </div>
            </div>
        </form>
    </body>
</html>
