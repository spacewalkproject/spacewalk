<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>

<br><br>
<bean:message key="channel.manage.errata.confirmmsg"/>
<br><br>
 <rl:listset name="packageConfirm">
	 <input type="hidden" name="cid" value="${cid}">

			<div class="left-column">
						<h2>Errata Summary:</h2>
						<table class="details">
							<tr>
									<th><img src="/img/wrh-bug.gif"    alt="<bean:message key="erratalist.jsp.bugadvisory"/>" />
										Bug Fix Advisory:
									</th>
									<td>${bug_count}</td>
							</tr>
							<tr>
									<th><img src="/img/wrh-product.gif"   alt="<bean:message key="erratalist.jsp.productenhancementadvisory"/>" />
										Product Enhancement Advisory:
									</th>
									<td>${enhance_count}</td>
							</tr>							
							<tr>
									<th><img src="/img/wrh-security.gif"  alt="<bean:message key="erratalist.jsp.securityadvisory"/>" />
										Security Advisory:
									</th>
									<td>${secure_count}</td>
							</tr>
							<tr>
									<th>Total Errata:</th>
									<td>${bug_count + enhance_count + secure_count}</td>
							</tr>																		
							<tr>
								<td colspan="2" class="csv-download">
									<rl:csv  name="errataList" dataset="errataList" exportColumns="advisory, advisorySynopsis, advisoryType, updateDate" />
								</td>
							</tr>
						</table>
						
			</div>
			<div class="right-column">
						<h2>Package Summary:</h2>
						<table class="details">

									<c:forEach var="option" items="${arch_count}">
										<tr>
											<th>
													${option.name}
											</th>
											<td>
													${option.size}
											</td>
										</tr>
									</c:forEach>
									<tr>
										<th>
												Total Packages:
										</th>
										<td>
												${totalSize}
										</td>
									</tr>
									<tr>
										<td colspan="2" class="csv-download">
											<rl:csv  name="packageList" dataset="packageList" exportColumns="id,packageName,packageNvre,packageArch,summary" />
										</td>
									</tr>	

						</table>

					

					
			</div>
	
			<hr />
			<p align="right">
				<input type="submit" name="dispatch"  value="<bean:message key="Clone Errata"/>"
		            <c:choose>
		                <c:when test="${totalSize < 1}">disabled</c:when>
		            </c:choose>					
				>
			</p>







 </rl:listset>


</body>
</html>
