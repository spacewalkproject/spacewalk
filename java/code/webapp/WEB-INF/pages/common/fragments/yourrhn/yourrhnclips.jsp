<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
<c:when test="${not empty requestScope.pageUrl}">
<c:import url="${requestScope.pageUrl}"/>
</c:when>
</c:choose>

<hr/>

<p>
Possible Urls
</p>
<a href="/rhn/YourRhnClips.do?key=critical-systems">critical-systems </a><br/>
<a href="/rhn/YourRhnClips.do?key=critical-probes">critical-probes </a><br/>
<a href="/rhn/YourRhnClips.do?key=warning-probes">warning-probes</a><br/>
<a href="/rhn/YourRhnClips.do?key=system-groups-widget">system-groups-widget</a><br/>
<a href="/rhn/YourRhnClips.do?key=latest-errata">latest-errata</a><br/>
<a href="/rhn/YourRhnClips.do?key=pending-actions">pending-actions</a><br/>
<a href="/rhn/YourRhnClips.do?key=recently-registered-systems">recently-registered-systems</a><br/>

