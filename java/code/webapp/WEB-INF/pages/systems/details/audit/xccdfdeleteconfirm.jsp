<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><bean:message key="system.audit.xccdfdeleteconfirm.jsp.overview"/></h2>

<rl:listset name="xccdfScans">
	<rhn:csrf/>
	<input type="hidden" name="sid" value="${param.sid}">

	<rl:list dataset="pageList" name="xccdfScans">
		<rl:decorator name="ElaborationDecorator"/>

		<rl:column headerkey="system.audit.listscap.jsp.testresult">
			<c:choose>
			<c:when test="${not empty current.comparableId}">
				<a href="/rhn/audit/scap/DiffSubmit.do?first=${current.comparableId}&second=${current.xid}&view=changed">
				<img src="/img/rhn-listicon-${current.diffIcon}.gif"
					alt="<bean:message key="scapdiff.jsp.i.${current.diffIcon}"/>"
					title="<bean:message key="scapdiff.jsp.i.${current.diffIcon}"/>"/></a>
			</c:when>
			<c:otherwise>
				<img src="/img/icon_checkin.gif"
					alt="<bean:message key="system.audit.xccdfdetails.jsp.nodiff"/>"
					title="<bean:message key="system.audit.xccdfdetails.jsp.nodiff"/>"/>
			</c:otherwise>
			</c:choose>&nbsp;

			<a href="/rhn/systems/details/audit/XccdfDetails.do?sid=${param.sid}&xid=${current.xid}">
				${current.testResult}
			</a>
		</rl:column>
		<rl:column headerkey="system.audit.listscap.jsp.completed">
			${current.completed}
		</rl:column>
		<rl:column headerkey="system.audit.listscap.jsp.percentage">
			<c:choose>
				<c:when test="${current.sum - current.notselected - current.informational == 0}">
					<bean:message key="system.audit.listscap.jsp.na"/>
				</c:when>
				<c:otherwise>
					<fmt:formatNumber maxFractionDigits="0"
						value="${current.pass * 100 /
						(current.sum - current.notselected - current.informational)}"/>
					%
				</c:otherwise>
			</c:choose>
		</rl:column>
		<rl:column headerkey="system.audit.xccdfdeleteconfirm.jsp.deletable">
			<c:choose>
				<c:when test="${current.deletable}">
					<img src="/img/rhn-listicon-checked_immutable.gif">
				</c:when>
				<c:otherwise>
					<img src="/img/rhn-listicon-unchecked_immutable.gif">
				</c:otherwise>
			</c:choose>
		</rl:column>
	</rl:list>

	<p align="right">
		<input type="submit" name="dispatch"  value="<bean:message key="confirm.jsp.confirm"/>">
	</p>
</rl:listset>

<span class="small-text">
	<bean:message key="system.audit.xccdfdeleteconfirm.jsp.tip"/>
</span>
</body>
</html>
