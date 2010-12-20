<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
<body>
    <h1>

      <img src="/img/rhn-icon-system_group.gif" alt="system group" />
      <bean:message key="systemgroup.create.header"/>
      <a href="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-group-creation" target="_new" class="help-title"><img src="/img/rhn-icon-help.gif" alt="Help Icon" /></a>
    </h1>

  <p><bean:message key="systemgroup.create.summary"/></p>
    <p><span class="required-form-field">*</span> - <bean:message key="systemgroup.create.requiredfield"/></p>

    <c:if test="${not empty emptynameordesc}">
      <div class="local-alert"><bean:message key="systemgroup.create.requirements"/><br /></div>
    </c:if>
    <c:if test="${not empty alreadyexists}">
      <div class="local-alert"><bean:message key="systemgroup.create.alreadyexists"/><br /></div>
    </c:if>

    <html:form method="post" action="/groups/CreateGroup.do">
      <html:hidden property="submitted" value="true"/>

      <table class="details">
        <tr>
          <th><bean:message key="systemgroup.create.name"/><span class="required-form-field">*</span>:</th>
          <td><html:text property="name" size="30" styleId="name" maxlength="64" /></td>
        </tr>

        <tr>
          <th><bean:message key="systemgroup.create.description" /><span class="required-form-field">*</span>:</th>
          <td><html:textarea property="description" cols="40" rows="4" styleId="description"/></td>
        </tr>
      </table>

<%--
      <div align="right">
        <hr />
        <input type="hidden" name="pxt:trap" value="rhn:server_group_create_cb" />
        <input type="hidden" name="redirect_to" value="/rhn/systems/SystemGroupList.do" />
        <input type="submit" name="make_group" value="<bean:message key="systemgroup.create.creategroup" />" />
--%>

      <hr/>
      <div align="right">
        <html:submit>
          <bean:message key="systemgroup.create.creategroup"/>
        </html:submit>
      </div>
    </html:form>


	</td>
      </tr>
    </table>


