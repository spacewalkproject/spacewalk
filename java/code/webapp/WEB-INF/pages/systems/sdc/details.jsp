<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2><bean:message key="sdc.details.edit.header"/></h2>

    <html:form method="post" action="/systems/details/Edit.do?sid=${system.id}">
      <html:hidden property="submitted" value="true"/>
    <table class="details">
      <tr>
        <th><label for="system_name"><bean:message key="sdc.details.edit.profilename"/></label></th>
        <td><html:text property="system_name" maxlength="128" size="40" styleId="system_name"/></td>
      </tr>
      <tr>
        <th><label for="baseentitlement"><bean:message key="sdc.details.edit.baseentitlement"/></label></th>
        <td>
          <c:choose>
            <c:when test="${!base_entitlement_permanent}">
              <rhn:require acl="user_role(org_admin)">
                <html:select property="base_entitlement" styleId="baseentitlement">
                  <html:options collection="base_entitlement_options" property="value" labelProperty="label"/>
                </html:select>
              </rhn:require>
              <rhn:require acl="not user_role(org_admin)">
                <c:out value="${base_entitlement}"/>
              </rhn:require>
            </c:when>
            <c:otherwise>
              <c:out value="${base_entitlement}"/>
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.addonentitlements"/></th>
          <td>
            <c:choose>
              <c:when test="${system.baseEntitlement == null}">
                <bean:message key="sdc.details.edit.nobase"/>
              </c:when>
              <c:otherwise>
                <c:forEach items="${addon_entitlements}" var="entitlement">
                  <html:checkbox property="${entitlement.entitlement.label}" styleId="${entitlement.entitlement.label}"/> <label for="${entitlement.entitlement.label}"><c:out value="${entitlement.entitlement.humanReadableLabel}"/>
                      <strong>(${entitlement.availbleEntitlements} <bean:message key="sdc.channels.edit.available"/>)</strong></label> <br/>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.notifications"/></th>
          <td>
            <c:choose>
              <c:when test="${notifications_disabled}">
                <bean:message key="sdc.details.overview.notifications.disabled"/>
              </c:when>
              <c:when test="${system.baseEntitlement == null}">
                <bean:message key="sdc.details.edit.notifications.unentitled"/>
              </c:when>
              <c:otherwise>
                <html:checkbox property="receive_notifications" styleId="receive_notifications"/> <label for="receive_notifications"><bean:message key="sdc.details.edit.updates"/></label><br/>
                <html:checkbox property="include_in_daily_summary" styleId="summary"/> <label for="summary"><bean:message key="sdc.details.edit.summary"/></label>
              </c:otherwise>
            </c:choose>
          </td>
      </tr>
      <tr>
        <th><label for="autoerrataupdate"><bean:message key="sdc.details.edit.autoerrataupdate"/></label></th>
        <td>
          <c:choose>
            <c:when test="${system.baseEntitlement == null}">
              <bean:message key="sdc.details.edit.autoupdate.unentitled"/>
            </c:when>
            <c:otherwise>
              <html:checkbox property="auto_update" styleId="autoerrataupdate"/> <label for="autoerrataupdate"><bean:message key="sdc.details.edit.autoupdate"/></label>
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr>
        <th><label for="description"><bean:message key="sdc.details.edit.description"/></label></th>
        <td><html:textarea property="description" cols="40" rows="6" styleId="description"/></td>
      </tr>
      <tr>
        <th><label for="address"><bean:message key="sdc.details.edit.address"/></label></th>
        <td><html:text property="address1" maxlength="128" size="30" styleId="address"/> <br/>
            <html:text property="address2" maxlength="128" size="30" /></td>
      </tr>
      <tr>
        <th><label for="city"><bean:message key="sdc.details.edit.city"/></label></th>
        <td><html:text property="city" maxlength="128" size="20" styleId="city"/></td>
      </tr>
      <tr>
        <th><label for="state"><bean:message key="sdc.details.edit.state"/></label></th>
        <td><html:text property="state" maxlength="60" size="20" styleId="state"/></td>
      </tr>
      <tr>
        <th><label for="country"><bean:message key="sdc.details.edit.country"/></label></th>
          <td>
            <html:select property="country" styleId="country">
              <html:options collection="countries"
                            property="value"
                            labelProperty="label" />
            </html:select>
          </td>
      </tr>
      <tr>
        <th><label for="building"><bean:message key="sdc.details.edit.building"/></label></th>
        <td><html:text property="building" maxlength="128" size="16" styleId="building"/></td>
      </tr>
      <tr>
        <th><label for="room"><bean:message key="sdc.details.edit.room"/></label></th>
        <td><html:text property="room" maxlength="32" size="16" styleId="room"/></td>
      </tr>
      <tr>
        <th><label for="rack"><bean:message key="sdc.details.edit.rack"/></label></th>
        <td><html:text property="rack" maxlength="64" size="10" styleId="rack"/></td>
      </tr>
    </table>

      <hr/>
        <div align="right">
          <html:submit>
            <bean:message key="sdc.details.edit.update"/>
          </html:submit>
        </div>
    </html:form>
  </body>
</html:html>
