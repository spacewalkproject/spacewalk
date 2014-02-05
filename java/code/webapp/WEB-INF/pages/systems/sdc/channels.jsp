<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
  <h2>
    <rhn:icon type="header-channel" title="common.download.channelAlt" />
    <bean:message key="sdc.channels.edit.header2"/>
  </h2>
  <html:form method="post" styleClass="form-horizontal" action="/systems/details/SystemChannels.do?sid=${system.id}">
    <rhn:csrf />
    <html:hidden property="submitted" value="true"/>
      <p><bean:message key="sdc.channels.edit.summary"/></p>
      <c:choose>
        <c:when test="${system.baseChannel == null}">
            <div class="form-group">
                    <div class="alert alert-warning">
                        <bean:message key="sdc.channels.edit.nobasechannel"/>
                    </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="form-group">
          <ul class="list-group">
            <li class="list-group-item">
                <a href="/rhn/channels/ChannelDetail.do?cid=${system.baseChannel.id}">${system.baseChannel.name}</a>
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
                    <a href="/rhn/channels/ChannelDetail.do?cid=${channel.id}">${channel.name}</a>
                    <c:if test="${system.virtualGuest}">
                      <c:if test="${not channel.freeForGuests}">
                        <span class="asterisk">*&nbsp;</span>
                        <c:set var="display_asterisk" value="true" scope="page" />
                      </c:if>
                      <c:choose>
                        <c:when test="${channel.freeForGuests && system.virtualInstance.hostSystem != null}">
                          (<bean:message key="sdc.channels.edit.unlimited"/>)
                        </c:when>

                        <c:when test="${server_fve_eligible && channel.availableFveSubscriptions > 0}">
                          (<strong>${channel.availableFveSubscriptions}</strong> flex <bean:message key="sdc.channels.edit.available"/>)
                        </c:when>

                        <c:otherwise>
                          <c:if test="${channel.availableSubscriptions == null}">
                            (<bean:message key="sdc.channels.edit.unlimited"/>)
                          </c:if>
                          <c:if test="${channel.availableSubscriptions != null}">
                            (<strong>${channel.availableSubscriptions}</strong> <bean:message key="sdc.channels.edit.available"/>)
                          </c:if>
                        </c:otherwise>
                      </c:choose>
                    </c:if>
                    <c:if test="${not system.virtualGuest}">
                      <c:if test="${channel.availableSubscriptions == null}">
                        (<bean:message key="sdc.channels.edit.unlimited"/>)
                      </c:if>
                      <c:if test="${channel.availableSubscriptions != null}">
                        (<strong>${channel.availableSubscriptions}</strong> <bean:message key="sdc.channels.edit.available"/>)
                      </c:if>
                    </c:if>
                  </li>
                </c:forEach>
              </ul>
            </li>
          </ul>
            </div>
        </c:otherwise>
      </c:choose>
      <c:if test="${pageScope.display_asterisk}">
        <c:if test="${not empty system.virtualInstance.hostSystem.id}">
            <div class="form-group">
                    <span class="help-block">
                        <span class="asterisk">*&nbsp;</span>
                        <bean:message key="sdc.channels.edit.virtsubwarning"
                                      arg0="${system.virtualInstance.hostSystem.id}"
                                      arg1="${system.virtualInstance.hostSystem.name}"/>
                    </span>
            </div>
        </c:if>
        <c:if test="${empty system.virtualInstance.hostSystem.id}">
            <div class="form-group">
                    <span class="help-block">
                        <span class="asterisk">*&nbsp;</span>
                        <bean:message key="sdc.channels.edit.virtsubwarning_nohost"/>
                    </span>
            </div>
        </c:if>
      </c:if>
      <div class="form-group">
              <html:submit property="dispatch" styleClass="form-horizontal pull-right">
                  <bean:message key="sdc.channels.edit.update_sub"/>
              </html:submit>
      </div>

      <rhn:require acl="not system_is_proxy(); not system_is_satellite()" mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">

      <h2>
          <rhn:icon type="header-channel" />
          <bean:message key="sdc.channels.edit.base_software_channel"/>
      </h2>
      <p>
          <bean:message key="sdc.channels.edit.summary2"/>
      </p>

      <div class="form-group">
          <div class="col-md-offset-3 col-md-6">
              <select class="form-control" name="new_base_channel_id" size="${fn:length(base_channels)+fn:length(custom_base_channels)+3}">
                  <option value="-1" <c:if test="${current_base_channel_id == -1}">selected="selected"</c:if> />
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
            </div>
          </div>
           <div class="form-group">
              <span class="help-block">
                  <bean:message key="sdc.channels.edit.fastrackBetaWarning"/>
              </span>
          </div>
              <html:submit property="dispatch" styleClass="btn btn-success pull-right">
                  <bean:message key="sdc.channels.edit.confirm_update_base"/>
              </html:submit>
      </rhn:require>
  </html:form>
</body>
</html:html>
