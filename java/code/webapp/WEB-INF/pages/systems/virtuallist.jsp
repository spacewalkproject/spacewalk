<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="fa-desktop"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-list-virtual">
  <bean:message key="virtuallist.jsp.toolbar"/>
</rhn:toolbar>

<form method="POST" name="rhn_list" action="/rhn/systems/VirtualSystemsListSubmit.do">
  <rhn:csrf />
  <rhn:list pageList="${requestScope.pageList}" noDataText="virtuallist.jsp.nosystems"
          legend="system">

  <rhn:virtuallistdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}"
                   filterBy="virtuallist.jsp.system" domainClass="systems">

    <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
      <c:choose>
        <c:when test="${current.selectable}">
          <rhn:set value="${current.systemId}"/>
        </c:when>
        <c:otherwise>
          <rhn:set value="0" disabled="true"
                   title="virtuallist.jsp.disabled_checkbox_title"
                   alt="virtuallist.jsp.disabled_checkbox_title"/>
        </c:otherwise>
      </c:choose>
    </rhn:require>

    <c:choose>
      <c:when test="${current.isVirtualHost && current.hostSystemId != 0}">
        <rhn:column header="virtuallist.jsp.name" colspan="4">
          <img src="/img/channel_parent_node.gif" />
          <bean:message key="virtuallist.jsp.host"/>:
          <a href="/rhn/systems/details/Overview.do?sid=${current.hostSystemId}">
            <c:out value="${current.serverName}" escapeXml="true" />
          </a>
          <bean:message key="virtuallist.jsp.hoststatus" arg0="${current.countActiveInstances}" arg1="${current.countTotalInstances}"/>
          <c:if test="${current.virtEntitlement != null}">
	          (<a href="/rhn/systems/details/virtualization/VirtualGuestsList.do?sid=${current.hostSystemId}"><bean:message key="virtuallist.jsp.viewall"/></a>)
	       </c:if>
        </rhn:column>
      </c:when>
      <c:when test="${current.isVirtualHost}">
        <rhn:column header="virtuallist.jsp.name" colspan="4">
          <img src="/img/channel_parent_node.gif" />
          <bean:message key="virtuallist.jsp.host"/>:
          <span style="color: #808080">
            <c:out value="${current.serverName}" escapeXml="true" />
          </span>
        </rhn:column>
      </c:when>
      <c:otherwise>

        <rhn:column header="virtuallist.jsp.name">
          <img src="/img/channel_child_node.gif" />
          <c:choose>
            <c:when test="${current.virtualSystemId == null}">
              <c:out value="${current.name}" escapeXml="true" />
            </c:when>
	        <c:when test="${current.accessible}">
	          <a href="/rhn/systems/details/Overview.do?sid=${current.virtualSystemId}">
                <c:out value="${current.serverName}" escapeXml="true" />
	          </a>
	        </c:when>
	        <c:otherwise>
              <c:out value="${current.serverName}" escapeXml="true" />
	        </c:otherwise>
          </c:choose>
        </rhn:column>

        <rhn:column header="virtuallist.jsp.updates"
                    style="text-align: center;">
            ${current.statusDisplay}
        </rhn:column>

        <rhn:column header="virtuallist.jsp.state">
          <c:out value="${current.serverName}" escapeXml="true" />
        </rhn:column>

        <rhn:column header="virtuallist.jsp.channel">
    		<c:choose>
        		<c:when test="${current.channelId == null}">
            		<bean:message key="none.message"/>
            	</c:when>
		        <c:when test="${current.subscribable}">
		                    <a href="/rhn/channels/ChannelDetail.do?cid=${current.channelId}">
		            ${current.channelLabels}
		          </a>
			        </c:when>
			        <c:otherwise>
			            ${current.channelLabels}
			        </c:otherwise>
		      </c:choose>
        </rhn:column>

      </c:otherwise>
    </c:choose>

  </rhn:virtuallistdisplay>

  </rhn:list>
</form>

</div>

</body>
</html>

