<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<div class="sideleg">
  <h2><bean:message key="probes-list-legend.jsp.title"/></h2>
  <ul>
  <li><img src="/img/rhn-mon-ok.gif" title="<bean:message key='monitoring.status.ok'/>"
       alt="<bean:message key='monitoring.status.ok'/>"/>
    <bean:message key="probes-list-legend.jsp.ok"/>
  </li>
  <li><img src="/img/rhn-mon-warning.gif" title="<bean:message key='monitoring.status.warn'/>"
       alt="<bean:message key='monitoring.status.warn'/>"/>
    <bean:message key="probes-list-legend.jsp.warning"/>
  </li>
  <li><img src="/img/rhn-mon-down.gif" title="<bean:message key='monitoring.status.critical'/>"
       alt="<bean:message key='monitoring.status.critical'/>"/>
    <bean:message key="probes-list-legend.jsp.critical"/>
  </li>
  <li><img src="/img/rhn-mon-unknown.gif" title="<bean:message key='monitoring.status.unknown'/>"
           alt="<bean:message key='monitoring.status.unknown'/>"/>
    <bean:message key="probes-list-legend.jsp.unknown"/>
  </li>
  <li><img src="/img/rhn-mon-pending.gif" title="<bean:message key='monitoring.status.pending'/>"
       alt="<bean:message key='monitoring.status.pending'/>"/>
    <bean:message key="probes-list-legend.jsp.pending"/>
  </li>
  </ul>
</div>

