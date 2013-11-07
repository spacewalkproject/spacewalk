<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="sdc.details.overview.systemstatus"/></h4>
    </div>
    <div class="panel-body">
        <c:choose>
          <c:when test="${unentitled}">
            <i class="spacewalk-icon-Unentitled"></i> <bean:message key="sdc.details.overview.unentitled" arg0="/rhn/systems/details/Edit.do?sid=${system.id}"/>
          </c:when>

          <c:when test="${systemInactive}">
            <i class="spacewalk-icon-unknown-system"/></i> <bean:message key="sdc.details.overview.inactive1"/>
            <c:if test="${documentation == 'true'}">
              <bean:message key="sdc.details.overview.inactive2" arg0="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-list"/>
            </c:if>
          </c:when>
          <c:when test="${hasUpdates}">
              <c:choose>
                  <c:when test="${criticalErrataCount > 0}">
                      <i class="fa fa-exclamation-circle fa-1-5x text-danger"></i>
                  </c:when>
                  <c:otherwise>
                      <i class="fa fa-exclamation-triangle fa-1-5x text-warning"></i>
                  </c:otherwise>
              </c:choose>

              &nbsp; <bean:message key="sdc.details.overview.updatesavailable" /> &nbsp;&nbsp;

              <c:if test="${criticalErrataCount > 0}">
                  <bean:message key="sdc.details.overview.updates.critical" arg0="/rhn/systems/details/ErrataList.do?sid=${system.id}&type=${rhn:localize('errata.create.securityadvisory')}" arg1="${criticalErrataCount}"/> &nbsp;&nbsp;
              </c:if>
              <c:if test="${nonCriticalErrataCount > 0}">
                  <bean:message key="sdc.details.overview.updates.noncritical" arg0="/rhn/systems/details/ErrataList.do?sid=${system.id}&type=${rhn:localize('errata.updates.noncritical')}" arg1="${nonCriticalErrataCount}"/> &nbsp;&nbsp;
              </c:if>
              <c:if test="${upgradablePackagesCount > 0}">
                  <bean:message key="sdc.details.overview.updates.packages" arg0="/rhn/systems/details/packages/UpgradableList.do?sid=${system.id}" arg1="${upgradablePackagesCount}"/>
              </c:if>
          </c:when>

          <c:otherwise>
           <i class="fa fa-check-circle fa-1-5x text-success"></i> <bean:message key="sdc.details.overview.updated"/>
          </c:otherwise>
        </c:choose>

        <c:if test="${rebootRequired}">
          <div class="systeminfo">
            <div class="systeminfo-full">
              <i class="fa fa-refresh text-primary"></i><bean:message key="sdc.details.overview.requires_reboot"/>
              <bean:message key="sdc.details.overview.schedulereboot" arg0="/network/systems/details/reboot_confirm.pxt?sid=${system.id}"/>
            </div>
          </div>
        </c:if>

        <c:if test="${probeListEmpty != 'true'}">
          <div class="row-0">
            <div class="col-md-6">
              <c:choose>
                <c:when test="${probeList[0].state == 'CRITICAL'}">
                  <i class="fa spacewalk-icon-monitoring-down"></i>  <bean:message key="sdc.details.overview.probes.critical" arg0="/rhn/help/reference/en-US/s1-sm-monitor.jsp"/>
                </c:when>
                <c:otherwise>
                  <i class="fa spacewalk-icon-monitoring-warning"></i>  <bean:message key="sdc.details.overview.probes.warning" arg0="/rhn/help/reference/en-US/s1-sm-monitor.jsp"/>
                </c:otherwise>
              </c:choose>
            </div>
            <div class="col-md-6">
              <c:forEach items="${probeList}" var="probe">
                <c:choose>
                  <c:when test="${probe.state == 'CRITICAL'}">
                    <i class="fa fa-circle text-danger"></i>
                  </c:when>
                  <c:otherwise>
                    <i class="fa fa-warning text-warning"></i>
                  </c:otherwise>
                </c:choose>
                <a href="/rhn/systems/details/probes/ProbeDetails.do?sid=${system.id}&probe_id=${probe.id}">${probe.description}</a><br/>
              </c:forEach>
            </div>
          </div>
        </c:if>

    </div>
  </div>
    

    <div class="systeminfo">

        



<div class="row-0">
  <div class="col-md-6">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="sdc.details.overview.systeminfo"/></h4>
      </div>
      <div class="panel-body">
        <table class="table">
          <tr>
            <td><bean:message key="sdc.details.overview.hostname"/></td>
            <td>
            <c:choose>
              <c:when test="${system.hostname == null}">
                <bean:message key="sdc.details.overview.unknown"/>
              </c:when>
              <c:otherwise>
                <c:out value="${system.decodedHostname}" />
              </c:otherwise>
            </c:choose>
            </td>
          </tr>
          <tr>
            <td><bean:message key="sdc.details.overview.ipaddy"/></td>
            <td>
            <c:choose>
              <c:when test="${system.ipAddress == null}">
                <bean:message key="sdc.details.overview.unknown"/>
              </c:when>
              <c:otherwise>
                <c:out value="${system.ipAddress}" />
              </c:otherwise>
            </c:choose>
            </td>
          </tr>
          <tr>
            <td><bean:message key="sdc.details.overview.ip6addy"/></td>
            <td>
            <c:choose>
              <c:when test="${system.ip6Address == null}">
                <bean:message key="sdc.details.overview.unknown"/>
              </c:when>
              <c:otherwise>
                <c:out value="${system.ip6Address}" />
              </c:otherwise>
            </c:choose>
            </td>
          </tr>
          <c:if test="${system.virtualGuest}">
            <tr>
              <td><bean:message key="sdc.details.overview.virtualization"/></td>
              <td>${system.virtualInstance.type.name}</td>
            </tr>
            <tr>
              <td><bean:message key="sdc.details.overview.uuid"/></td>
              <c:choose>
                <c:when test="${system.virtualInstance.uuid == null}">
                  <td>
                    <bean:message key="sdc.details.overview.unknown"/>
                  </td>
                </c:when>
                <c:otherwise>
                  <td>${system.virtualInstance.uuid}</td>
                </c:otherwise>
              </c:choose>
            </tr>
          </c:if>
          <tr>
            <td><bean:message key="sdc.details.overview.kernel"/></td>
            <td>
            <c:choose>
              <c:when test="${system.runningKernel == null}">
                <bean:message key="sdc.details.overview.unknown"/>
              </c:when>
              <c:otherwise>
                <c:out value="${system.runningKernel}" />
              </c:otherwise>
            </c:choose>
            </td>
          </tr>
          <tr>
            <td><bean:message key="sdc.details.overview.sysid"/></td>
            <td><c:out value="${system.id}" /></td>
          </tr>
         <tr>
            <td><bean:message key="sdc.details.overview.activationkey"/></td>
            <td>
              <c:forEach items="${activationKey}" var="key">
                <c:out value="${key.token}" /></br>
              </c:forEach>
            </td>
          </tr>
          <tr>
            <td><bean:message key="sdc.details.overview.lockstatus"/></td>
            <td>
            <c:choose>
              <c:when test="${serverLock != null}">
              <i class="fa fa-lock"></i>
              <bean:message key="sdc.details.overview.locked"
                            arg0="${serverLock.locker.login}"
                            arg1="${serverLock.reason}" /><br/>
              <bean:message key="sdc.details.overview.unlock" arg0="/rhn/systems/details/Overview.do?sid=${system.id}&amp;lock=0"/>
              </c:when>
              <c:otherwise>
                  <i class="fa fa-unlock"></i>
                  <bean:message key="sdc.details.overview.unlocked"/><br/>
                  <bean:message key="sdc.details.overview.lock" arg0="/rhn/systems/details/Overview.do?sid=${system.id}&amp;lock=1"/>
              </c:otherwise>
            </c:choose>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
  <div class="col-md-6">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="sdc.details.overview.sysevents"/></h4>
      </div>
      <div class="panel-body">
        <table class="table">
          <tr>
            <td><bean:message key="sdc.details.overview.checkedin"/></td>
            <td><fmt:formatDate value="${system.lastCheckin}" type="both" dateStyle="short" timeStyle="long"/></td>
          </tr>
          <tr>
            <td><bean:message key="sdc.details.overview.registered"/></td>
            <td><fmt:formatDate value="${system.created}" type="both" dateStyle="short" timeStyle="long"/></td>
          </tr>
          <tr>
            <td><bean:message key="sdc.details.overview.lastbooted"/></td>
            <td><fmt:formatDate value="${system.lastBootAsDate}" type="both" dateStyle="short" timeStyle="long"/><br/>
                  <rhn:require acl="system_feature(ftr_reboot)"
                       mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
                <bean:message key="sdc.details.overview.schedulereboot" arg0="/network/systems/details/reboot_confirm.pxt?sid=${system.id}"/>
                  </rhn:require>
            </td>
          </tr>
          <rhn:require acl="client_capable(osad.ping); system_feature(ftr_osa_bus)"
                       mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
            <tr>
              <td><bean:message key="sdc.details.overview.osa.status"/></td>
              <td>
                <c:choose>
                  <c:when test="${system.pushClient != null}">
                    <bean:message key="sdc.details.overview.osa.status.message"
                                  arg0="${system.pushClient.state.name}"/>
                    <c:choose>
                        <c:when test="${system.pushClient.lastMessageTime != null}">
                            <fmt:formatDate value="${system.pushClient.lastMessageTime}" type="both" dateStyle="short" timeStyle="long"/><br/>
                        </c:when>
                        <c:otherwise>
                            <bean:message key="sdc.details.overview.unknown" /><br/>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${system.pushClient.lastPingTime != null}">
                        <bean:message key="sdc.details.overview.osa.status.lastping"/>
                        <fmt:formatDate value="${system.pushClient.lastPingTime}" type="both" dateStyle="short" timeStyle="long"/>
                        <br/>
                    </c:if>

                    <a href="/rhn/systems/details/Overview.do?sid=${system.id}&amp;ping=1"><bean:message key="sdc.details.overview.osa.status.ping"/></a>
                  </c:when>
                  <c:otherwise>
                    <bean:message key="sdc.details.overview.unknown" />
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </rhn:require>
          <rhn:require acl="system_feature(ftr_satellite_applet); client_capable(rhn_applet.use_satellite)"
                       mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
            <tr>
              <td><bean:message key="sdc.details.overview.applet"/></td>
              <td>
                <c:choose>
                  <c:when test="${system.serverUuid == null}">
                    <bean:message key="sdc.details.overview.applet.notactivated"/><br/>
                    <a href="/rhn/systems/details/Overview.do?sid=${system.id}&amp;applet=1"/><bean:message key="sdc.details.overview.applet.activate"/></a>
                  </c:when>
                  <c:otherwise>
                    <bean:message key="sdc.details.overview.applet.activated"/><br/>
                    <a href="/rhn/systems/details/Overview.do?sid=${system.id}&amp;applet=1"/><bean:message key="sdc.details.overview.applet.reactivate"/></a>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </rhn:require>
        </table>
      </div>
    </div>
  </div>
</div>

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="sdc.details.overview.sysproperties" arg0="/rhn/systems/details/Edit.do?sid=${system.id}"/></h4>
    </div>
    <div class="panel-body">
      <table class="table">
        <tr>
          <td><bean:message key="sdc.details.overview.entitlement"/></td>
          <td>
          <c:choose>
            <c:when test="${unentitled}">
              <bean:message key="none.message"/>
            </c:when>
            <c:otherwise>

              <c:forEach items="${system.entitlements}" var="entitlement">
                [${entitlement.humanReadableLabel}]
              </c:forEach>

            </c:otherwise>
          </c:choose>
          </td>
        </tr>
        <tr>
          <td><bean:message key="sdc.details.overview.notifications"/></td>
          <td>

          <c:choose>
            <c:when test="${unentitled}">
              <bean:message key="none.message"/>
            </c:when>
            <c:otherwise>

              <c:forEach items="${prefs}" var="pref">
                <bean:message key="${pref}"/><br/>
              </c:forEach>

            </c:otherwise>
          </c:choose>
          </td>
        </tr>
        <rhn:require acl="system_feature(ftr_errata_updates)"
                     mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
        <tr>
          <td><bean:message key="sdc.details.overview.errataupdate"/></td>
          <td><c:choose>
                <c:when test="${system.autoUpdate == 'Y'}">
                <bean:message key="yes"/>
                </c:when>
                <c:otherwise>
                <bean:message key="no"/>
                </c:otherwise>
              </c:choose>
          </td>
        </tr>
        </rhn:require>
        <tr>
          <td><bean:message key="sdc.details.overview.sysname"/></td>
          <td><c:out value="${system.name}"/></td>
        </tr>
        <tr>
          <td><bean:message key="sdc.details.overview.description"/></td>
          <td>${description}</td>
        </tr>
        <tr>
          <td><bean:message key="sdc.details.overview.location"/></td>
          <td>
            <c:choose>
              <c:when test="${not hasLocation}">
                <bean:message key="sdc.details.overview.location.none"/>
              </c:when>
              <c:otherwise>
                <bean:message key="sdc.details.overview.location.room"/>: <c:out value="${system.location.room}"/><br/>
                <bean:message key="sdc.details.overview.location.rack"/>: <c:out value="${system.location.rack}"/><br/>
                <bean:message key="sdc.details.overview.location.building"/>: <c:out value="${system.location.building}"/><br/>
                <c:out value="${system.location.address1}"/><br/>
                <c:out value="${system.location.address2}"/><br/>
                <c:out value="${system.location.city}"/> <c:out value="${system.location.state}"/> <c:out value="${system.location.country}"/>
              </c:otherwise>
            </c:choose>
          </td>
        </tr>
      </table>
    </div>
  </div>

  <rhn:require acl="client_capable(abrt.check);" mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="sdc.details.overview.crashes.application"/></h4>
      </div>
      <div class="panel-body">
        <table class="table">
          <c:choose>
            <c:when test="${system.crashCount == null}">
              <bean:message key="sdc.details.overview.crashes.nodata"/>
            </c:when>
            <c:otherwise>
              <tr>
                <td><bean:message key="sdc.details.overview.crashes.uniquecrashcount"/></td>
                <td><a href="/rhn/systems/details/SoftwareCrashes.do?sid=${system.id}"><c:out value="${system.crashCount.uniqueCrashCount}"/></a></td>
              </tr>
              <tr>
                <td><bean:message key="sdc.details.overview.crashes.totalcrashcount"/></td>
                <td><a href="/rhn/systems/details/SoftwareCrashes.do?sid=${system.id}"><c:out value="${system.crashCount.totalCrashCount}"/></a></td>
              </tr>
              <tr>
                <td><bean:message key="sdc.details.overview.crashes.lastreport"/></td>
                <td><fmt:formatDate value="${system.crashCount.lastReport}" type="both" dateStyle="short" timeStyle="long"/></td>
              </tr>

            </c:otherwise>
          </c:choose>
        </table>
      </div>
    </div>
  </rhn:require>
  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="sdc.details.overview.subscribedchannels" arg0="/rhn/systems/details/SystemChannels.do?sid=${system.id}"/></h4>
    </div>
    <div class="panel-body">
      <c:if test="${system.baseChannel != null}">
        <ul class="channel-list">
        <li>
          <a href="/rhn/channels/ChannelDetail.do?cid=${baseChannel['id']}">${baseChannel['name']}</a>
          <c:if test="${baseChannel['is_fve'] == 'Y'}">
            &nbsp;(Flex)
          </c:if>
        </li>

        <c:forEach items="${childChannels}" var="childChannel">
        <li class="child-channel">
          <a href="/rhn/channels/ChannelDetail.do?cid=${childChannel['id']}">${childChannel['name']}</a>
          <c:if test="${childChannel['is_fve'] == 'Y'}">
            &nbsp;(Flex)
          </c:if>
        </li>
        </c:forEach>

        </ul>
      </c:if>
    </div>
  </div>
</body>
</html:html>
