<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<h2><bean:message key="ssm.overview.header"/></h2>
<div class="page-summary">
    <ul><bean:message key="ssm.overview.summary"/></ul>
    <ul><bean:message key="ssm.overview.summary2"/></ul>
</div>


<div class="panel panel-default">
    <ul class="list-group">
        <li class="list-group-item">
            <div class="row">
                <div class="col-sm-2">
                    <rhn:icon type="header-system" title="ssm.overview.systems" />
                    <bean:message key="ssm.overview.systems"/>
                </div>
                <div class="col-sm-10">
                    <bean:message key="ssm.overview.systems.list"/>
                </div>
            </div>
        </li>
        <li class="list-group-item">
            <div class="row">
                <div class="col-sm-2">
                    <rhn:icon type="header-errata" title="ssm.overview.errata" />
                    <bean:message key="ssm.overview.errata"/>
                </div>
                <div class="col-sm-10">
                    <bean:message key="ssm.overview.errata.schedule"/>
                </div>
            </div>
        </li>
        <li class="list-group-item">
            <div class="row">
                <div class="col-sm-2">
                  <rhn:icon type="header-package" title="ssm.overview.packages" />
                    <bean:message key="ssm.overview.packages"/>
                </div>
                <div class="col-sm-10">
                    <bean:message key="ssm.overview.packages.upgrade"/>
                </div>
            </div>
        </li>
        <rhn:require acl="user_role(org_admin)">
            <li class="list-group-item">
                <div class="row">
                    <div class="col-sm-2">
                      <rhn:icon type="header-system-groups" title="ssm.overview.groups" />
                        <bean:message key="ssm.overview.groups"/>
                    </div>
                    <div class="col-sm-10">
                        <bean:message key="ssm.overview.groups.create"/>
                    </div>
                </div>
            </li>
        </rhn:require>
        <li class="list-group-item">
            <div class="row">
                <div class="col-sm-2">
                  <rhn:icon type="header-channel" title="ssm.overview.channels" />
                    <bean:message key="ssm.overview.channels"/>
                </div>
                <div class="col-sm-10">
                    <ul>
                        <li><bean:message key="ssm.overview.channels.memberships"/></li>
                        <rhn:require acl="user_role(config_admin)">
                          <li><bean:message key="ssm.overview.channels.subscriptions"/></li>
                          <li><bean:message key="ssm.overview.channels.deploy"/></li>
                        </rhn:require>
                    </ul>
                </div>
            </div>
        </li>
        <li class="list-group-item">
            <div class="row">
                <div class="col-sm-2">
                  <rhn:icon type="header-kickstart" title="ssm.overview.provisioning" />
                    <bean:message key="ssm.overview.provisioning"/>
                </div>
                <div class="col-sm-10">
                    <ul>
                        <li><bean:message key="ssm.overview.provisioning.kickstart"/></li>
                        <li><bean:message key="ssm.overview.provisioning.rollback"/></li>
                        <li><bean:message key="ssm.overview.provisioning.remotecommands"/></li>
                        <li><bean:message key="ssm.overview.provisioning.powermanagement.configure"/></li>
                        <li><bean:message key="ssm.overview.provisioning.powermanagement.operations"/></li>
                    </ul>
                </div>
            </div>
        </li>
        <li class="list-group-item">
            <div class="row">
                <div class="col-sm-2">
                  <rhn:icon type="header-event-history" title="ssm.overview.misc" />
                    <bean:message key="ssm.overview.misc"/>
                </div>
                <div class="col-sm-10">
                    <ul>
                        <li><bean:message key="ssm.overview.misc.updateprofiles"/></li>
                        <li><bean:message key="ssm.overview.misc.customvalues"/></li>
                        <rhn:require acl="user_role(org_admin)">
                            <li><bean:message key="ssm.overview.misc.entitlements"/></li>
                        </rhn:require>
                        <li><bean:message key="ssm.overview.misc.delete"/></li>
                        <li><bean:message key="ssm.overview.misc.reboot"/></li>
                        <li><bean:message key="ssm.overview.misc.migrate"/></li>
                        <li><bean:message key="ssm.overview.misc.lock"/></li>
                        <li><bean:message key="ssm.overview.misc.scap"/></li>
                    </ul>
                </div>
            </div>
        </li>
    </ul>
 
</div>

</body>
</html>
