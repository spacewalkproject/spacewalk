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
          <rhn:icon type="system-unentitled" /> <bean:message key="sdc.details.overview.unentitled" arg0="/rhn/systems/details/Edit.do?sid=${system.id}"/>
        </c:when>
        <c:otherwise>
          <rhn:require acl="system_has_management_entitlement()">
              <c:choose>
                <c:when test="${systemInactive}">
                  <rhn:icon type="system-unknown" /> <bean:message key="sdc.details.overview.inactive1"/>
                </c:when>
                <c:when test="${hasUpdates}">
                  <c:choose>
                    <c:when test="${criticalErrataCount > 0}">
                      <rhn:icon type="system-crit" />
                    </c:when>
                    <c:otherwise>
                      <rhn:icon type="system-warn" />
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
                  <rhn:icon type="system-ok" /> <bean:message key="sdc.details.overview.updated"/>
                </c:otherwise>
              </c:choose>

              <c:if test="${rebootRequired}">
                <div class="systeminfo">
                  <div class="systeminfo-full">
                    <rhn:icon type="system-reboot" /><bean:message key="sdc.details.overview.requires_reboot"/>
                    <bean:message key="sdc.details.overview.schedulereboot" arg0="/rhn/systems/details/RebootSystem.do?sid=${system.id}"/>
                  </div>
                </div>
              </c:if>
          </rhn:require>
          </c:otherwise>
      </c:choose>
    </div>
  </div>

  <div class="row-0">
    <div class="col-md-6">

      <!-- System Info box -->
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="sdc.details.overview.systeminfo"/></h4>
        </div>
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
              <td><c:out value="${system.virtualInstance.type.name}"/></td>
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
          <rhn:require acl="system_has_management_entitlement()">
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
                    <rhn:icon type="system-locked" />
                  <bean:message key="sdc.details.overview.locked"
                          arg0="${serverLock.locker.login}"
                          arg1="${serverLock.reason}" /><br/>
                  <bean:message key="sdc.details.overview.unlock" arg0="/rhn/systems/details/Overview.do?sid=${system.id}&amp;lock=0"/>
                </c:when>
                <c:otherwise>
                  <rhn:icon type="system-physical" />
                  <bean:message key="sdc.details.overview.unlocked"/><br/>
                  <bean:message key="sdc.details.overview.lock" arg0="/rhn/systems/details/Overview.do?sid=${system.id}&amp;lock=1"/>
                </c:otherwise>
              </c:choose>
            </td>
          </tr>
          </rhn:require>
        </table>
      </div>

      <rhn:require acl="system_has_management_entitlement()">
      <!-- Channel subcriptions -->
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="sdc.details.overview.subscribedchannels" arg0="/rhn/systems/details/SystemChannels.do?sid=${system.id}"/></h4>
        </div>
        <div class="panel-body">
          <c:if test="${system.baseChannel != null}">
            <ul class="channel-list">
            <li>
              <a href="/rhn/channels/ChannelDetail.do?cid=${baseChannel['id']}"><c:out value="${baseChannel['name']}" /></a>
            </li>

            <c:forEach items="${childChannels}" var="childChannel">
            <li class="child-channel">
              <a href="/rhn/channels/ChannelDetail.do?cid=${childChannel['id']}"><c:out value="${childChannel['name']}" /></a>
            </li>
            </c:forEach>

            </ul>
          </c:if>
        </div>
      </div>
      </rhn:require>
    </div>

    <div class="col-md-6">

      <!-- System events box -->
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="sdc.details.overview.sysevents"/></h4>
        </div>
        <table class="table">
          <tr>
            <td><bean:message key="sdc.details.overview.checkedin"/></td>
            <td><rhn:formatDate humanStyle="calendar" value="${system.lastCheckin}" type="both" dateStyle="short" timeStyle="long"/></td>
          </tr>
          <rhn:require acl="system_has_management_entitlement()">
          <tr>
            <td><bean:message key="sdc.details.overview.registered"/></td>
            <td><rhn:formatDate humanStyle="calendar" value="${system.created}" type="both" dateStyle="short" timeStyle="long"/></td>
          </tr>
          </rhn:require>
          <tr>
            <td><bean:message key="sdc.details.overview.lastbooted"/></td>
            <td><rhn:formatDate humanStyle="from" value="${system.lastBootAsDate}" type="both" dateStyle="short" timeStyle="long"/><br/>
                  <rhn:require acl="system_feature(ftr_reboot)"
                       mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
                <bean:message key="sdc.details.overview.schedulereboot" arg0="/rhn/systems/details/RebootSystem.do?sid=${system.id}"/>
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

      <!-- System Properties box -->
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="sdc.details.overview.sysproperties" arg0="/rhn/systems/details/Edit.do?sid=${system.id}"/></h4>
        </div>
        <table class="table">
          <tr>
            <td><bean:message key="sdc.details.overview.entitlement"/></td>
            <td>
            <c:choose>
              <c:when test="${unentitled}">
                <bean:message key="none.message"/>
              </c:when>
              <c:otherwise>
                <rhn:require acl="system_has_management_entitlement()">
                <c:forEach items="${system.entitlements}" var="entitlement">
                 [<c:out value="${entitlement.humanReadableLabel}" />]
                </c:forEach>
                </rhn:require>
               </c:otherwise>
            </c:choose>
            </td>
          </tr>
          <rhn:require acl="system_has_management_entitlement()">
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
          </rhn:require>
          <rhn:require acl="system_feature(ftr_errata_updates)"
                     mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
          <tr>
            <td><bean:message key="sdc.details.overview.errataupdate"/></td>
            <td>
              <c:choose>
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
            <td><c:out value="${description}" escapeXml="false"/></td> <!-- already html-escaped in backend -->
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
  </div>

  <rhn:require acl="client_capable(abrt.check);" mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="sdc.details.overview.crashes.application"/></h4>
      </div>
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
  </rhn:require>

</body>
</html:html>
