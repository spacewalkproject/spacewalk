<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html:xhtml/>
<html>

<head>
<script src="/javascript/channel_tree.js" type="text/javascript"></script>
<script type="text/javascript">
var filtered = ${requestScope.isFiltered};
function showFiltered() {
  if (filtered)
    ShowAll();
}
</script>
</head>

<body onLoad="onLoadStuff(3); showFiltered();"> 

<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif" imgAlt="channels.overview.toolbar.imgAlt"
             helpUrl="/rhn/help/reference/en/s2-sm-channel-list.jsp#s3-sm-channel-list-all" >
  <bean:message key="channels.all.jsp.toolbar"/>
</rhn:toolbar>

<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tabs.jspf" %>

<p>
	<bean:message key="channels.all.jsp.header1" />
</p>

<form method="post" name="rhn_list" action="/rhn/software/channels/All.do">
  <rhn:list pageList="${requestScope.pageList}" noDataText="channels.overview.nochannels">
        <rhn:unpagedlistdisplay filterBy="channels.overview.filterby" type="treeview">
                    <c:choose>
                        <c:when test="${current.accessible}">
                            <rhn:column header="channels.overview.name"
                                        url="/rhn/channels/ChannelDetail.do?cid=${current.id}"
                                        usesRefactoredList="true">
                                <c:choose>
                                    <c:when test="${current.depth > 1}">
                                            <img style="margin-left: 4px;" src="/img/channel_child_node.gif" alt="<bean:message key='channels.childchannel.alt' />" />
                                            ${current.name}
                                    </c:when>
                                       <c:otherwise>
                                        ${current.name}
                                       </c:otherwise>
                                   </c:choose>
                               </rhn:column>
                        </c:when>
                           <c:otherwise>
                            <rhn:column header="channels.overview.name" usesRefactoredList="true">
                                   ${current.name}
                            </rhn:column>
                           </c:otherwise>
                       </c:choose>
                       <rhn:column header="channels.overview.packages" 
                                  url="/rhn/multiorg/OrgDetails.do?oid=${current.orgId}" 
                                  style="text-align: right;"
                                  usesRefactoredList="true">
                          ${current.orgName}
                      </rhn:column>
                       <rhn:column header="channels.overview.packages" 
                                  url="/rhn/channels/ChannelPackages.do?cid=${current.id}" 
                                  style="text-align: right;"
                                  usesRefactoredList="true">
                          ${current.packageCount}
                      </rhn:column>
                     <c:choose>
                        <c:when test="${current.accessible}">
                            <rhn:column header="channels.overview.systems"
                                    url="/rhn/channels/ChannelSubscribers.do?cid=${current.id}"
                                    style="text-align: right;"
                                    usesRefactoredList="true">
                                <c:choose>
                                    <c:when test="${current.systemCount == null}">
                                    0
                                    </c:when>
                                    <c:otherwise>
                                        ${current.systemCount}
                                    </c:otherwise>
                                </c:choose>
                            </rhn:column>
                        </c:when>
                        <c:otherwise>
                            <rhn:column header="channels.overview.systems" usesRefactoredList="true" 
                                style="text-align: right;">
                                   ${current.systemCount}
                            </rhn:column>
                        </c:otherwise>
                        </c:choose>
        </rhn:unpagedlistdisplay>
  </rhn:list>
</form>

</body>
</html>
