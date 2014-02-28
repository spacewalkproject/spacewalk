<%--
    Document   : ssm-errata
    Created on : Aug 22, 2013, 1:18:24 PM
    Author     : Bo Maryniuk
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ page import="com.redhat.rhn.frontend.action.ssm.ErrataListAction" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="ssm.patches.list.header" /></h2>
        <p><bean:message key="ssm.patches.list.summary" /></p>

        <rl:listset name="errataListSet" legend="errata">
            <rhn:csrf />
            <rhn:submitted />

            <br/>
            <select name="type">
                <c:forEach items="${combo}" var="item">
                        <option id="${item.id}"
                                <c:if test="${item['default']}"> selected</c:if>
                                >  <bean:message key="${item.name}"/>
                        </option>
                </c:forEach>
            </select>
            <html:submit styleClass="btn btn-default" property="show">
                <bean:message key="system.errata.show"/>
            </html:submit>
            <br/>
<%@ include file="/WEB-INF/pages/ssm/systems/errata-list-fragment.jspf" %>

            <div class="text-right">
                <hr />
                <html:submit styleClass="btn btn-default" property="dispatch">
                    <bean:message key="errata.jsp.apply"/>
                </html:submit>
            </div>
            <rhn:submitted/>
        </rl:listset>
    </body>
</html>
