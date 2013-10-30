<%--
    Document   : reboot-systems
    Created on : Jul 16, 2013, 2:35:54 PM
    Author     : Bo Maryniuk <bo@suse.de>
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="ssm.misc.reboot.header" /></h2>
        <p><bean:message key="ssm.misc.reboot.summary" /></p>

        <rl:listset name="systemsListSet" legend="system">
            <c:set var="noCsv" value="1"/>
            <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
            <div class="text-right">
                <div align="left">
                    <p><bean:message key="installconfirm.jsp.widgetsummary"/></p>
                    <table class="details" align="center">
                        <tr>
                            <th><label for="radio_use_date_than"><bean:message key="confirm.jsp.than"/></label></th>
                            <td>
                                <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                    <jsp:param name="widget" value="date"/>
                                </jsp:include>
                            </td>
                        </tr>
                    </table>
                </div>
                <hr/>
                <input type="submit" name="dispatch" value='<bean:message key="installconfirm.jsp.confirm"/>'/>
            </div>
        </rl:listset>
    </body>
</html>
