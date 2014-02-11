<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
        <bean:message key="virtualguestslist.jsp.header" />
</h2>
<div class="page-summary">
        <p>
        <bean:message key="virtualguestslist.jsp.summary" />
        </p>
</div>

<html:form action="/systems/details/virtualization/VirtualGuestsListSubmit.do">
  <rhn:csrf />
  <rhn:list pageList="${requestScope.pageList}" noDataText="virtualguestslist.jsp.nosystems"
          legend="system">

  <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}"
                   filterBy="virtualguestslist.jsp.guestname" domainClass="systems">

    <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
      <c:choose>
        <c:when test="${current.selectable}">
          <rhn:set value="${current.id}"/>
        </c:when>
        <c:otherwise>
          <rhn:set value="0" disabled="true"
                   title="virtualguestslist.jsp.disabled_checkbox_title"
                   alt="virtualguestslist.jsp.disabled_checkbox_title"/>
        </c:otherwise>
      </c:choose>
    </rhn:require>

    <rhn:column header="virtualguestslist.jsp.guestname">
      <c:out value="${current.name}" escapeXml="true" />
    </rhn:column>

    <rhn:column header="systemlist.jsp.system">
      <c:choose>
        <c:when test="${current.virtualSystemId == null}">
          <bean:message key="virtualguestslist.jsp.unregistered" />
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

    <rhn:column header="virtualguestslist.jsp.updates"
                style="text-align: center;">
        ${current.statusDisplay}
    </rhn:column>

    <rhn:column header="virtualguestslist.jsp.state">
        ${current.stateName}
    </rhn:column>

    <rhn:column header="virtualguestslist.jsp.memory">
        ${current.memory / 1024} MB
    </rhn:column>

    <rhn:column header="virtualguestslist.jsp.vcpus">
        ${current.vcpus}
    </rhn:column>

    <rhn:column header="virtualguestslist.jsp.channel">
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

  </rhn:listdisplay>

  </rhn:list>

  <div class="text-right">

    <hr />
    <html:select property="guestAction">
        <html:optionsCollection name="actionOptions"/>
    </html:select>

    <html:submit styleClass="btn btn-default" property="dispatch">
        <bean:message key="virtualguestslist.jsp.applyaction"/>
    </html:submit>

  </div>
    <div class="text-right">
        <bean:message key="virtualguestslist.jsp.set"/>
        <html:select property="guestSettingToModify">
            <html:optionsCollection name="guestSettingOptions"/>
        </html:select>
        <bean:message key="virtualguestslist.jsp.allocationtoequal"/>
        <html:text property="guestSettingValue"/>
        <html:submit styleClass="btn btn-default" property="dispatch">
            <bean:message key="virtualguestslist.jsp.applychanges"/>
        </html:submit>
    </div>

  <input type="hidden" name="sid" value="${param.sid}" />
  <rhn:submitted/>

</html:form>

</div>

</body>
</html>

