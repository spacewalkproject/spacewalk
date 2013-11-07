<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
    <body>
        <rhn:toolbar base="h1" icon="icon-user" imgAlt="user.common.userAlt">
            <bean:message key="Addresses"/>
        </rhn:toolbar>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4>
                    ${editAddressForm.map.typedisplay}
                    <bean:message key="your_edit_address_record.displayname"/>
                </h4>
            </div>
            <div class="panel-body">
                <p>
                    <bean:message key="your_edit_address.jsp.summary" />
                </p>
                <hr>
                <html:form action="/account/EditAddressSubmit" styleClass="form-horizontal">
                    <rhn:csrf />
                    <%@ include file="/WEB-INF/pages/common/fragments/user/edit_address_form.jspf" %>
                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <button type="submit"
                                    class="btn btn-success"
                                    value="<bean:message key='button.update'/>">
                                <bean:message key="button.update"/>
                            </button>
                        </div>
                    </div>
                    <html:hidden property="uid" value="${param.uid}"/>
                    <html:hidden property="type"/>
                </html:form>
            </div>
        </div>
    </body>
</html>
