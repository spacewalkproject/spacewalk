<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <head>
        <meta name="name" value="activationkeys.jsp.header" />
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>
        <html:form action="/activationkeys/packages/Packages" styleClass="form-horizontal">
            <rhn:csrf />
            <p><bean:message key="activation-key.packages.jsp.summary"/></p>
            <h2><bean:message key="activation-key.packages.jsp.enter-names"/></h2>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:textarea styleClass="form-control"
                                   property="packages" rows="8" cols="64" />
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <rhn:submitted/>
                    <input class="btn btn-success" type="submit"
                           name ="dispatch" value='<bean:message key="keyedit.jsp.submit"/>'/>
                </div>
            </div>
            <html:hidden property="submitted" value="true" />
            <c:if test='${not empty param.tid}'>
                <html:hidden property="tid" value="${param.tid}" />
            </c:if>
        </html:form>
    </body>
</html>
