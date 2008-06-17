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
        <th><bean:message key="sdc.details.edit.profilename"/></th>
        <td><html:text property="system_name" maxlength="128" size="40" /></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.baseentitlement"/></th>
        <td>
          <c:choose>
            <c:when test="${!base_entitlement_permanent}">
              <rhn:require acl="user_role(org_admin)">
                <html:select property="base_entitlement">
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
                  <html:checkbox property="${entitlement.entitlement.label}"/> <c:out value="${entitlement.entitlement.humanReadableLabel}"/> 
                      <strong>(${entitlement.availbleEntitlements} <bean:message key="sdc.channels.edit.available"/>)</strong> <br/>
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
                <html:checkbox property="receive_notifications"/> <bean:message key="sdc.details.edit.updates"/><br/>
                <html:checkbox property="include_in_daily_summary"/> <bean:message key="sdc.details.edit.summary"/>
              </c:otherwise>
            </c:choose>
          </td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.autoerrataupdate"/></th>
        <td>
          <c:choose>
            <c:when test="${system.baseEntitlement == null}">
              <bean:message key="sdc.details.edit.autoupdate.unentitled"/>
            </c:when>
            <c:otherwise>
              <html:checkbox property="auto_update"/> <bean:message key="sdc.details.edit.autoupdate"/>
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.description"/></th>
        <td><html:textarea property="description" cols="40" rows="6"/></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.address"/></th>
        <td><html:text property="address1" maxlength="128" size="30" /> <br/>
            <html:text property="address2" maxlength="128" size="30" /></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.city"/></th>
        <td><html:text property="city" maxlength="128" size="20" /></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.state"/></th>
        <td><html:text property="state" maxlength="60" size="20" /></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.country"/></th>
          <td>
            <html:select property="country">
              <html:options collection="countries"
                            property="value"
                            labelProperty="label" />
            </html:select>
          </td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.building"/></th>
        <td><html:text property="building" maxlength="128" size="16" /></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.room"/></th>
        <td><html:text property="room" maxlength="32" size="16" /></td>
      </tr>
      <tr>
        <th><bean:message key="sdc.details.edit.rack"/></th>
        <td><html:text property="rack" maxlength="64" size="10" /></td>
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
