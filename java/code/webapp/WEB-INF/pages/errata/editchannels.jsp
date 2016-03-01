<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
                   helpUrl="">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><bean:message key="errata.edit.editerrata"/></h2>

  <p><bean:message key="errata.edit.channels.instructions"/></p>
<c:set var="pageList" value="${requestScope.pageList}" />
<form method="POST" name="rhn_list" action="/rhn/errata/manage/ChannelsSubmit.do">
<rhn:csrf />
<rhn:list pageList="${requestScope.pageList}" noDataText="errata.publish.nochannels">
  <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}">
    <rhn:set value="${current.id}" />
    <rhn:column header="errata.publish.channelname" url="/rhn/channels/ChannelDetail.do?cid=${current.id}">
        <c:out value="${current.name}"/>
    </rhn:column>

    <rhn:column header="errata.publish.relevantpackages">
        <c:if test="${current.relevantPackages > 0}">
            <a href="/rhn/errata/manage/ErrataChannelIntersection.do?cid=<c:out value="${current.id}"/>&eid=<c:out value="${param.eid}"/>">
        </c:if>
        <c:out value="${current.relevantPackages}"/>
        <c:if test="${current.relevantPackages > 0}">
            </a>
        </c:if>
    </rhn:column>

  </rhn:listdisplay>
</rhn:list>
<hr />
<rhn:hidden name="eid" value="${param.eid}" />
<rhn:hidden name="returnvisit" value="${param.returnvisit}"/>
<div class="text-right">
  <html:submit styleClass="btn btn-default" property="dispatch">
    <bean:message key="errata.channels.updatechannels"/>
  </html:submit>
</div>
</form>
</body>
</html>
