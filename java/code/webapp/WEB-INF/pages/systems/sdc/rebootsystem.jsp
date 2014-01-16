<%--
    Document   : rebootsystem
    Created on : Jan 15, 2014, 2:35:54 PM
    Author     : Michael Calmer <mc@suse.de>
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="reboot.jsp.header" /></h4>
            </div>
            <div class="panel-body">
                <bean:message key="reboot.jsp.summary" />
                <br>
                <bean:message key="reboot.jsp.widgetsummary"/>

                <form action="/rhn/systems/details/RebootSystem.do?sid=${sid}" method="post" class="form-horizontal">
                    <rhn:csrf />
                    <rhn:submitted />

                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="date"/>
                            </jsp:include>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <html:submit styleClass="btn btn-danger">
                                <bean:message key="reboot.jsp.confirm"/>
                            </html:submit>
                        </div>
                    </div>

                    <input type="hidden" name="use_date" value="true" />
                </form>
            </div>
        </div>
    </body>
</html>
