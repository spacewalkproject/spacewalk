<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
  <h2>
    <img src="/img/rhn-icon-channels.gif" alt="channel"/>
    <bean:message key="sdc.channels.edit.header2"/>
  </h2>
  <html:form method="post" action="/systems/details/SystemChannels.do?sid=${system.id}">
    <html:hidden property="submitted" value="true"/>
    <table class="details">
      <div class="page-summary">
        <p>
          <bean:message key="sdc.channels.edit.summary"/>
        </p>
      </div>
      <!--div class="resubscribe-warning-big">
       <img src="/img/rhn-icon-warning.gif" title="<bean:message key="sdc.channels.edit.resubwarning"/>" /> <bean:message key="sdc.channels.edit.markedwarning"/>
      </div-->
      <c:choose>
        <c:when test="${system.baseChannel == null}">
          <bean:message key="sdc.channels.edit.nobasechannel"/>
        </c:when>
        <c:otherwise>
          <ul class="list-channel">
            <li><a href="/rhn/channels/ChannelDetail.do?cid=${system.baseChannel.id}">${system.baseChannel.name}</a>
              <ul>
                <c:forEach items="${avail_child_channels}" var="channel">
                  <c:choose>
                    <c:when test="${not channel.subscribable}">
                      <c:set var="disabledChannel" scope="page" value="disabled=\"true\" alt=\"disabled\""/>
                    </c:when>
                    <c:otherwise>
                      <c:set var="disabledChannel" scope="page" value="alt=\"enabled\""/>
                    </c:otherwise>
                  </c:choose>
                  <li>
                    <c:if test="${channel.subscribed}">
                      <input ${disabledChannel} name="child_channel" value="${channel.id}" checked="1" type="checkbox" id="checked">
                    </c:if>
                    <c:if test="${not channel.subscribed}">
                      <input ${disabledChannel} name="child_channel" value="${channel.id}" type="checkbox" id="unchecked">
                    </c:if>
                    <c:if test="${not channel.freeForGuests && system.virtualGuest}">
                      <span class="asterisk">*&nbsp;</span>
                    </c:if>
                    <a href="/rhn/channels/ChannelDetail.do?cid=${channel.id}">${channel.name}</a>
                    <c:if test="${channel.availableSubscriptions != null}">
                      (<strong>${channel.availableSubscriptions}</strong> <bean:message key="sdc.channels.edit.available"/>)
                    </c:if>
                    <c:if test="${channel.availableSubscriptions == null}">
                      (<bean:message key="sdc.channels.edit.unlimited"/>)
                    </c:if>
                  </li>
                </c:forEach>
              </ul>
            </li>
          </ul>
        </c:otherwise>
      </c:choose>
      <c:if test="${system.virtualGuest}">
        <c:if test="${not empty system.virtualInstance.hostSystem.id}">
          <span class="asterisk">*&nbsp;</span><bean:message key="sdc.channels.edit.virtsubwarning" arg0="${system.virtualInstance.hostSystem.id}"
            arg1="${system.virtualInstance.hostSystem.name}"/>
        </c:if>
        <c:if test="${empty system.virtualInstance.hostSystem.id}">
          <span class="asterisk">*&nbsp;</span><bean:message key="sdc.channels.edit.virtsubwarning_nohost"/>
        </c:if>
      </c:if>
      <hr/>
      <div align="right">
        <html:submit property="dispatch">
          <bean:message key="sdc.channels.edit.update_sub"/>
        </html:submit>
      </div>
      <rhn:require acl="not system_is_proxy(); not system_is_satellite()" mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">

        <h2>
          <img src="/img/rhn-icon-channels.gif" />
          <bean:message key="sdc.channels.edit.base_software_channel"/>
        </h2>


        <div class="page-summary">
          <p>
            <bean:message key="sdc.channels.edit.summary2"/>
            <!--div class="resubscribe-warning-big">
            <p>
              <img src="/img/rhn-icon-warning.gif" title="<bean:message key="sdc.channels.edit.resubwarning"/>" /> <bean:message key="sdc.channels.edit.subwarning"/>
            </p>
            </div-->
          <p/>
          <select name="new_base_channel_id" size="10">
            <option value="-1"
            	<c:if test="${current_base_channel_id == -1}">
            		selected="selected"
            	</c:if>  >
            	<bean:message key="sdc.channels.edit.no_base_channel"/></option>
            <c:if test="${not empty custom_base_channels}">
              <optgroup label='<bean:message key="basesub.jsp.rhn-channels"/>'>
            </c:if>
            <c:forEach items="${base_channels}" var="chan">
              <c:choose>
                <c:when test="${current_base_channel_id == chan.id}">
                  <option value="${chan.id}" selected="selected"><c:out value="${chan.name}" /></option>
                </c:when>
                <c:otherwise>
                  <option value="${chan.id}"><c:out value="${chan.name}" /></option>
                </c:otherwise>
              </c:choose>
            </c:forEach>
            <c:if test="${not empty custom_base_channels}">
              </optgroup>
            </c:if>
            <c:if test="${not empty custom_base_channels}">
              <optgroup label='<bean:message key="basesub.jsp.custom-channels"/>'>
                <c:forEach items="${custom_base_channels}" var="chan">
                  <c:choose>
                    <c:when test="${current_base_channel_id == chan.id}">
                      <option value="${chan.id}" selected="selected"><c:out value="${chan.name}" /></option>
                    </c:when>
                    <c:otherwise>
                      <option value="${chan.id}"><c:out value="${chan.name}" /></option>
                    </c:otherwise>
                  </c:choose>
                </c:forEach>
              </optgroup>
            </c:if>
          </select>

          <hr/>
          <div align="right">
            <html:submit property="dispatch">
              <bean:message key="sdc.channels.edit.confirm_update_base"/>
            </html:submit>
          </div>

          <span class="small-text">
            <bean:message key="sdc.channels.edit.fastrackBetaWarning"/>
          </span>
        </div>
      </rhn:require>
    </table>
  </html:form>
</body>
</html:html>
