<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
    <head>
        <script language="javascript" type="text/javascript">
          function toggle_checkboxes() {
            org_checkbox = document.getElementById('role_org_admin');
            sat_checkbox = document.getElementById('role_satellite_admin');
            role_checkboxes = document.getElementsByName('regular_role');
            for (var i = 0, n = role_checkboxes.length; i < n; i++) {
              if (org_checkbox.checked) {
                role_checkboxes[i].checked = org_checkbox.checked;
              }
              role_checkboxes[i].disabled = org_checkbox.checked;
            }
          }

          function collect_regular_roles() {
            selected = document.getElementById('selected_regular_roles');
            role_checkboxes = document.getElementsByName('regular_role');
            selected.value = '';
            for (var i = 0, n = role_checkboxes.length; i < n; i++) {
              if (role_checkboxes[i].checked) {
                selected.value += role_checkboxes[i].id + ' ';
              }
            }
          }
        </script>
    </head>
    <body onLoad="toggle_checkboxes()">

        <c:choose>
            <c:when test="${empty gid}">
                <rhn:toolbar base="h1" icon="header-channel-mapping" iconAlt="info.alt.img">
                    <bean:message key="extgroup.jsp.create"/>
                </rhn:toolbar>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" icon="header-channel-mapping" iconAlt="info.alt.img"
                             deletionUrl="ExtGroupDelete.do?gid=${gid}"
                             deletionType="extgroup">
                    <bean:message key="extgroup.jsp.update" arg0="${group.label}"/>
                </rhn:toolbar>
            </c:otherwise>
        </c:choose>

        <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/admin_user.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

        <div class="page-summary">
            <p><bean:message key="extgroups.jsp.summary"/></p>
            <p><bean:message key="extgroup.jsp.summary"/></p>
        </div>
        <div class="panel-heading">
            <h4><bean:message key="extgroup.jsp.header"/></h4>
        </div>

            <form method="post" action="/rhn/admin/multiorg/ExtGroupDetails.do?gid=${gid}" class="form-horizontal" onSubmit="collect_regular_roles()">
                <rhn:submitted/>
                <rhn:csrf />
                <div class="form-group">
                    <label class="col-lg-3 control-label"><bean:message key="extgrouplist.jsp.name"/>:</label>
                       <div class="col-lg-6">
                          <input type="text" class="form-control" name="extGroupLabel" value="${group.label}" />
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label"><bean:message key="userdetails.jsp.adminRoles"/>:</label>
                       <div class="col-lg-6">
                            <c:forEach items="${adminRoles}" var="role">
                              <div class="checkbox">
                                <label>
                                    <input type="checkbox" id="role_${role.value}" name="role_${role.value}" onchange="toggle_checkboxes()"
                                           <c:if test="${role.selected}">checked="true"</c:if>
                                           <c:if test="${role.disabled}">disabled="true"</c:if>
                                    />
                                    ${role.label}
                                </label>
                              </div>
                            </c:forEach>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="userdetails.jsp.roles"/>:
                    </label>
                       <div class="col-lg-6">
                            <c:forEach items="${regularRoles}" var="role">
                              <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="regular_role" id="${role.value}"
                                           <c:if test="${role.selected}">checked="true"</c:if>
                                           <c:if test="${role.disabled}">disabled="true"</c:if>
                                    />
                                    ${role.label}
                                </label>
                              </div>
                            </c:forEach>
                    </div>
                </div>
                <input type="hidden" id="selected_regular_roles" name="selected_regular_roles"/>

                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <button type="submit" class="btn btn-success">
                            <c:choose>
                                <c:when test="${empty gid}">
                                    <bean:message key="button.create"/>
                                </c:when>
                                <c:otherwise>
                                    <bean:message key="button.update"/>
                            </c:otherwise>
                        </c:choose>
                        </button>
                    </div>
                </div>
            </form>
    </body>
</html:html>
