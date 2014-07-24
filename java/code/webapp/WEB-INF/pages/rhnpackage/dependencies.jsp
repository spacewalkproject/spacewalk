<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="channel.jsp.dependencies.requires.title"/>
</h2>
<p>
<c:if test="${requires != null}">
   <c:forEach items="${requires}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${requires == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.provides.title"/>
</h2>
<p>
<c:if test="${provides != null}">
   <c:forEach items="${provides}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${provides == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.obsoletes.title"/>
</h2>
<p>
<c:if test="${obsoletes != null}">
   <c:forEach items="${obsoletes}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${obsoletes == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.conflicts.title"/>
</h2>
<p>
<c:if test="${conflicts != null}">
   <c:forEach items="${conflicts}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${conflicts == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.recommends.title"/>
</h2>
<p>
<c:if test="${recommends != null}">
   <c:forEach items="${recommends}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${recommends == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.suggests.title"/>
</h2>
<p>
<c:if test="${suggests != null}">
   <c:forEach items="${suggests}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${suggests == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.supplements.title"/>
</h2>
<p>
<c:if test="${supplements != null}">
   <c:forEach items="${supplements}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${supplements == null}">
   &#160;
</c:if>
</p>

<h2>
<bean:message key="channel.jsp.dependencies.enhances.title"/>
</h2>
<p>
<c:if test="${enhances != null}">
   <c:forEach items="${enhances}" var="line">
                ${line}<br />
   </c:forEach>
</c:if>
<c:if test="${enhances == null}">
   &#160;
</c:if>
</p>

</body>
</html:html>
