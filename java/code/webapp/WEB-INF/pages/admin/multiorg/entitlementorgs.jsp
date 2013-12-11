<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<html:html>
<head>
    <script type="text/javascript" language="JavaScript">
        function setOrgClicked(target) {
          document.forms[0].orgClicked.value=target;
          alert(target);
        };
    </script>
</head>
<body>
  <rhn:toolbar base="h1" icon="header-channel"
               miscUrl="${url}"
               miscAcl="user_role(org_admin)"
               miscText="${text}"
               miscImg="${img}"
               miscAlt="${text}"
               imgAlt="users.jsp.imgAlt">
      <c:out value="${entname}"/>
  </rhn:toolbar>
  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/systemEntitlementOrgs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="entitlementorgs.miniheader"/></h4>
    </div>
    <div class="panel-body">
      <p><bean:message key="entitlementorgs.description" arg0="${enthuman}"/></p>
      <rl:listset name="entitlementSet">
        <rhn:csrf />
        <!-- Reuse the form opened by the list tag -->
        <html:hidden property="submitted" value="true"/>
        <html:hidden property="orgClicked" value="0"/>
        <rl:list dataset="pageList"
                 width="100%"
                 name="pageList"
                 filter="com.redhat.rhn.frontend.action.multiorg.SystemEntitlementOrgsFilter"
                 styleclass="list"
                 emptykey="sys_entitlements.noentorgs">
            <rl:column bound="false"
                       sortable="false"
                       headerkey="entitlementorgs.orgname">

                <a href="/rhn/admin/multiorg/OrgDetails.do?oid=${current.orgid}">${current.name}</a>
            </rl:column>
            <rl:column bound="false"
                       sortable="false"
                       headerkey="entitlementorgs.total">
                ${current.total}
            </rl:column>
            <rl:column bound="false"
                       sortable="false"
                       headerkey="entitlementorgs.used">
                ${current.usage}
            </rl:column>
            <rl:column bound="false"
                       sortable="false"
                       headerkey="entitlementorgs.proposed_total">
                <div class="row">
                    <div class="col-lg-1">
                        <div class="input-group">
                            <span class="input-group-btn">
                                <html:text property="newCount_${current.orgid}" size="5" value="${current.total}"
                                           styleClass="form-control"
                                           onkeydown="return blockEnter(event)" />
                                <html:submit styleClass="btn btn-info" onclick="this.form.orgClicked.value = '${current.orgid}'">
                                    <bean:message key="entitlementorgs.update"/>
                                </html:submit>
                            </span>
                        </div>
                    </div>
                </div>
                <span class="help-block">
                    <bean:message key="entitlementorgs.jsp.possible_vals" arg0="${current.upper}"/>
                </span>
            </rl:column>
        </rl:list>
    </rl:listset>
    <p>
      <small>
        <bean:message key="entitlementorgs.tip"/>
      </small>
    </p>
    </div>
  </div>

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="entitlementorgs.usage"/></h4>
    </div>
    <div class="panel-body">
      <div class="form-horizontal">
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="entitlementorgs.total_allocated"/>:
            </label>
            <div class="col-lg-6">
                <div class="well well-sm">
                    ${maxEnt}
                </div>
                <span class="help-block">
                    <bean:message key="entitlementorgs.tip_allocated"/>
                </span>
            </div>
        </div>
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="entitlementorgs.total_inuse"/>:
            </label>
            <div class="col-lg-6">
                <div class="well well-sm">
                    ${curEnt}
                </div>
            </div>
        </div>
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="entitlementorgs.total_orguse"/>:
            </label>
            <div class="col-lg-6">
                <div class="well well-sm">
                    <bean:message key="entitlementorgs.total_orgusedata"
                                  arg0="${alloc}" arg1="${orgsnum}" arg2="${ratio}"/>
                </div>
            </div>
        </div>
    </div>
    </div>
  </div>
</body>
</html:html>
