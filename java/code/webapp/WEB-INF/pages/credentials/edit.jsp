<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html:xhtml/>
<html>
    <body>
        <rhn:toolbar base="h1" icon="fa-user" imgAlt="users.jsp.imgAlt"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account"
                     deletionUrl="/rhn/account/DeleteCredentials.do"
                     deletionType="credentials">
            <bean:message key="Credentials"/>
        </rhn:toolbar>
        <p>
            <bean:message key="credentials.jsp.edit.summary" />
        </p>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="credentials.jsp.susestudio" /></h4>
            </div>
            <div class="panel-body">
                <form method="post" action="/rhn/account/Credentials.do"
                  class="form-horizontal" role="form">
                    <rhn:csrf />
                    <rhn:submitted />
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="credentials.jsp.username" />
                        </label>
                        <div class="col-lg-6">
                            <html:text property="studio_user" styleClass="form-control" value="${creds.username}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="credentials.jsp.apikey" />
                        </label>
                        <div class="col-lg-6">
                            <html:text property="studio_key" styleClass="form-control" value="${creds.password}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="credentials.jsp.url" />
                        </label>
                        <div class="col-lg-6">
                            <html:text property="studio_url" styleClass="form-control" value="${creds.url}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <button type="submit" class="btn btn-success">
                                <bean:message key="credentials.jsp.edit.dispatch" />
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>  
    </body>
</html>
