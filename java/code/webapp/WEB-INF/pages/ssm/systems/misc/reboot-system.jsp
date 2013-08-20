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
        
<html:xhtml/>
<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="ssm.misc.reboot.header" /></h2>
        <p><bean:message key="ssm.misc.reboot.summary" /></p>
            
        <rl:listset name="systemsListSet" legend="errata">
            <rhn:csrf />
            <rhn:submitted />
            <rl:list width="100%"
                     dataset="pageList"
                     name="systemList"
                     styleclass="list"
                     alphabarcolumn="name">
                <rl:decorator name="ElaborationDecorator"/>
                <rl:decorator name="PageSizeDecorator"/>
                <rl:decorator name="SelectableDecorator"/>
                    
                <rl:selectablecolumn value="${current.id}"
                                     selected="${current.selected}"
                                     disabled="${not current.selectable}"
                                     styleclass="first-column"/>
                <rl:column headerkey="systemlist.jsp.system" bound="false" sortattr="name" sortable="true">
                    <a href="/rhn/systems/details/Overview.do?sid=${current.id}">${current.name}</a>
                </rl:column>
                <rl:column headerkey="systemlist.jsp.channel" bound="false" sortattr="name" sortable="true" styleclass="last-column">
                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.channelId}">${current.channelLabels}</a>
                </rl:column>
                <rl:column headerkey="systemlist.jsp.entitlement" bound="false" sortattr="name" sortable="true" styleclass="last-column">
                    <c:choose>
                        <c:when test="${!empty current.addOnEntitlementLevel}">
                            ${current.baseEntitlementLevel}, ${current.addOnEntitlementLevel}
                        </c:when>
                        <c:otherwise>
                            ${current.baseEntitlementLevel}
                        </c:otherwise>
                    </c:choose>
                </rl:column>
            </rl:list>
            <div align="right">
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
