<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <bean:message key="ssmchildsubs.jsp.header" />
</h2>

    <div class="page-summary"><bean:message key="ssmchildsubs.jsp.summary"/></div>
    

  <rl:listset name="channellist">
    <rhn:csrf />
    <html:hidden property="submitted" value="true"/>

    <table width="100%">
	    <c:forEach items="${bases}" var="parent">
            <div class="ssm-child-stanza">
            <table width="100%">
                <tr>
                    <td width="50%"><strong>${parent.name}</strong></td>
                    <td class="text-right">
                        <c:choose>
                            <c:when test="${parent.systemCount == 1}">
                                <a href="/rhn/channels/ChannelSubscribers.do?cid=${parent.id}"><strong><bean:message key="ssmchildsubs.jsp.one-system"/></strong></a>
                            </c:when>
                            <c:otherwise>
                                <a href="/rhn/channels/ChannelSubscribers.do?cid=${parent.id}"><strong><bean:message key="ssmchildsubs.jsp.num-systems" arg0="${parent.systemCount}"/></strong></a>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </table>
            <c:forEach items="${parent.availableChildren}" var="child">
                <table width="100%">
                    <tr>
                        <td>&nbsp;</td>
                        <td width="35%">
                            <a href="/rhn/channels/ChannelDetail.do?cid=${child.id}">${child.name}</a>
                        </td>
                        <td nowrap>
                            <input type="radio" name="${child.id}" value="subscribe" align="center"/> <bean:message key="ssmchildsubs.jsp.subscribe"/>
                            <input type="radio" name="${child.id}" value="unsubscribe" align="center"/> <bean:message key="ssmchildsubs.jsp.unsubscribe"/>
                            <input type="radio" name="${child.id}" value="ignore" align="center" checked/> <bean:message key="ssmchildsubs.jsp.donothing"/>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${child.systemCount == 0}">
                                    <bean:message key="ssmchildsubs.jsp.no-system"/>
                                </c:when>
                                <c:when test="${child.systemCount == 1}">
                                    <a href="/rhn/channels/ChannelSubscribers.do?cid=${child.id}"><bean:message key="ssmchildsubs.jsp.one-system"/></a>
                                </c:when>
                                <c:otherwise>
                                    <a href="/rhn/channels/ChannelSubscribers.do?cid=${child.id}"><bean:message key="ssmchildsubs.jsp.num-systems" arg0="${child.systemCount}"/></a>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </div>
        </c:forEach>
    </table>
	<hr />
	<div class="text-right"><html:submit property="dispatch"><bean:message key="ssmchildsubs.jsp.alter"/></html:submit></div>
  </rl:listset>
</body>
</html>
