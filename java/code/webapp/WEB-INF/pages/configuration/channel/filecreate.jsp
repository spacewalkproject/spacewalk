<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <body>
        <%@ include
            file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

            <div class="createfragment">
                <!-- create file to channel  -->
                <h2><bean:message key="addfiles.jsp.create.jspf.title" /> </h2>
                <html:form
                    styleClass="form-horizontal"
                    action="/configuration/ChannelCreateFiles.do?ccid=${ccid}">
                    <rhn:csrf />
                    <rhn:submitted />
                    <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/create.jspf" %>
                </html:form>
            </div>

        </body>
    </html>

