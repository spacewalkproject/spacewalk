<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
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
      ${current.name}
    </rhn:column>

    <rhn:column header="systemlist.jsp.system">
      <c:choose>
        <c:when test="${current.virtualSystemId == null}">
          <bean:message key="virtualguestslist.jsp.unregistered" />
        </c:when>
        <c:otherwise>
          <a href="/rhn/systems/details/Overview.do?sid=${current.virtualSystemId}">
            ${current.serverName}
          </a>
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
        <c:otherwise>
          <a href="/rhn/channels/ChannelDetail.do?cid=${current.channelId}">
            ${current.channelLabels}
          </a>
        </c:otherwise>
      </c:choose>
    </rhn:column>

  </rhn:listdisplay>

  </rhn:list>

  <div align="right">

    <hr />
    <html:select property="guestAction">
        <html:optionsCollection name="actionOptions"/>
    </html:select>

    <html:submit property="dispatch">
        <bean:message key="virtualguestslist.jsp.applyaction"/>
    </html:submit>

  </div>
    <div align="right">
        <bean:message key="virtualguestslist.jsp.set"/>
        <html:select property="guestSettingToModify">
            <html:optionsCollection name="guestSettingOptions"/>
        </html:select>
        <bean:message key="virtualguestslist.jsp.allocationtoequal"/>
        <html:text property="guestSettingValue"/>
        <html:submit property="dispatch">
            <bean:message key="virtualguestslist.jsp.applychanges"/>
        </html:submit>
    </div>

  <input type="hidden" name="sid" value="${param.sid}" />
  <rhn:submitted/>

</html:form>

</div>

</body>
</html>

