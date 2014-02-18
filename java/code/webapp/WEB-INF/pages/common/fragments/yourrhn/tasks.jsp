<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<form method="post" name="rhn_list" action="/YourRhn.do">


  <div class="panel panel-default">

    <div class="panel-heading">
      <h3 class="panel-title">
        <bean:message key="yourrhn.jsp.task.title" />
      </h3>
    </div>

    <ul class="list-group">

      <rhn:require acl="not user_role(satellite_admin)">
        <rhn:require acl="user_role(org_admin)">
        <li class="list-group-item">
            <rhn:icon type="nav-bullet" /> <a
              href="/rhn/systems/SystemEntitlements.do"> <bean:message
                  key="yourrhn.jsp.tasks.subscriptions" />
            </a>
          </li>
        </rhn:require>
      </rhn:require>

      <rhn:require acl="user_role(satellite_admin)">
        <rhn:require acl="user_role(org_admin)">
          <li class="list-group-item">
          <rhn:icon type="nav-bullet" /> <bean:message
                key="yourrhn.jsp.task.manage_subscriptions" /> <br />
              &ensp; &ensp;<a href="/rhn/systems/SystemEntitlements.do">
                <bean:message key="header.jsp.my_organization" />
            </a> <strong>|</strong> <a
              href="/rhn/admin/multiorg/SoftwareEntitlements.do"><bean:message
                  key="header.jsp.satellite_wide" /> </a>
          </li>
        </rhn:require>
      </rhn:require>

      <rhn:require acl="user_role(satellite_admin)">
        <rhn:require acl="not user_role(org_admin)">
          <li class="list-group-item"><rhn:icon type="nav-bullet" /> <a
              href="/rhn/admin/multiorg/SoftwareEntitlements.do"> <bean:message
                  key="yourrhn.jsp.tasks.subscriptions" />
            </a>
          </li>
        </rhn:require>
      </rhn:require>

      <c:if test="${documentation == 'true'}">
        <li class="list-group-item">
        <rhn:icon type="nav-bullet" /> <a
            href="/rhn/help/client-config/en-US/index.jsp"> <bean:message
                key="yourrhn.jsp.tasks.registersystem" />
          </a>
        </li>
      </c:if>

      <rhn:require
        acl="org_entitlement(sw_mgr_enterprise); user_role(activation_key_admin)">
        <li class="list-group-item">
        <rhn:icon type="nav-bullet" /> <a
            href="/rhn/activationkeys/List.do"> <bean:message
                key="yourrhn.jsp.tasks.activationkeys" />
          </a>
        </li>

      </rhn:require>

      <rhn:require
        acl="org_entitlement(rhn_provisioning); user_role(config_admin)">
        <li class="list-group-item">
          <rhn:icon type="nav-bullet" /> <a
            href="/rhn/kickstart/KickstartOverview.do"> <bean:message
                key="yourrhn.jsp.tasks.kickstart" />
          </a>
        </li>

        <li class="list-group-item">
          <rhn:icon type="nav-bullet" /> <a
            href="/rhn/configuration/file/GlobalConfigFileList.do">
              <bean:message key="yourrhn.jsp.tasks.configuration" />
          </a>
        </li>

        <rhn:require acl="show_monitoring();"
          mixins="com.redhat.rhn.common.security.acl.MonitoringAclHandler">
          <li class="list-group-item">
            <rhn:icon type="nav-bullet" /> <a
              href="/rhn/monitoring/ProbeList.do"> <bean:message
                  key="yourrhn.jsp.tasks.monitoring" />
            </a>
          </li>
        </rhn:require>

        <rhn:require acl="user_role(satellite_admin)">
          <li class="list-group-item">
            <rhn:icon type="nav-bullet" /> <a
              href="/rhn/admin/multiorg/Organizations.do"> <bean:message
                  key="yourrhn.jsp.tasks.manage_sat_orgs" />
            </a>
          </li>
        </rhn:require>

      </rhn:require>

      <rhn:require acl="user_role(satellite_admin)">
        <li class="list-group-item">
          <rhn:icon type="nav-bullet" /> <a
            href="/rhn/admin/config/GeneralConfig.do"> <bean:message
                key="yourrhn.jsp.tasks.config_sat" />
          </a>
        </li>
      </rhn:require>


    </ul>


    <div class="panel-footer"></div>
  </div>

</form>
