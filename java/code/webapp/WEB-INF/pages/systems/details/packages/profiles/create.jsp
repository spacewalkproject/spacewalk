<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <h2><bean:message key="create.jsp.createstoredprofile"/></h2>
        <p><bean:message key="create.jsp.pagesummary"/></p>

        <html:form styleClass="form-horizontal" action="/systems/details/packages/profiles/Create">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-md-3 control-label">
                    <bean:message key="create.jsp.profilename" />:
                </label>
                <div class="col-md-6">
                    <html:text property="name" maxlength="128" size="48" styleClass="form-control"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-md-3 control-label">
                    <bean:message key="create.jsp.profiledescription" />:
                </label>
                <div class="col-md-6">
                    <html:textarea property="description" cols="48" rows="6" styleClass="form-control" />
                </div>
            </div>
          
            <div class="form-group">
                <div class="col-md-offset-3 col-md-6">
                    <html:hidden property="sid" value="${param.sid}" />
                    <html:hidden property="submitted" value="true" />
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="create.jsp.createprofile"/>
                    </html:submit>
                </div>
            </div>
        </html:form>
    </body>
</html>
