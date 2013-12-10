<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>

<!-- Setup the account_type variable, which is used throughout this page -->
<c:if test="${empty param.account_type}">
  <c:set var="account_type" value="create_corporate" scope="page" />
</c:if>
<c:if test="${!empty param.account_type}">
  <c:set var="account_type" value="${param.account_type}" scope="page"/>
</c:if>

<c:if test="${account_type == 'into_org'}" >
  <rhn:toolbar base="h1" icon="header-user" imgAlt="user.common.userAlt"
       helpUrl="/rhn/help/reference/en-US/s1-sm-users.jsp">
  <bean:message key="usercreate.toolbar" />
  </rhn:toolbar>
</c:if>


  <c:if test="${empty param.action_path}">
    <c:set var="action_path" value="/newlogin/CreateSatelliteSubmit" scope="page" />
  </c:if>
  <c:if test="${!empty param.action_path}">
    <c:set var="action_path" value="${param.action_path}" scope="page"/>
  </c:if>
<html:form action="${action_path}">

  <rhn:csrf />
  <div class="row-0">
    <div class="col-md-6">
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="usercreate.login" /></h4>
        </div>
        <div class="panel-body">
          <table class="table">
              <tr>
                <td><label for="login"><rhn:required-field key="desiredlogin"/>:</label></td>
                <td>
                  <html:text property="login" styleClass="form-control" maxlength="${loginLength}" styleId="login"/>
                </td>
              </tr>
              <tr>
                <td><label for="desiredpass"><bean:message key="desiredpass" /><span name="password-asterisk"
                      class="required-form-field">*</span>:</td></label>
                <td>
                  <html:password property="desiredpassword" styleClass="form-control" size="15" maxlength="${passwordLength}"/>
                </td>
              </tr>
              <tr>
                <td><label for="confirmpass"><bean:message key="confirmpass" /><span name="password-asterisk"
                      class="required-form-field">*</span>:</label></td>
                <td>
                  <html:password styleClass="form-control" property="desiredpasswordConfirm" size="15" maxlength="${passwordLength}" styleId="confirmpass"/>
                </td>
              </tr>
              <c:if test="${displaypam == 'true' && account_type != 'create_sat'}">
                <tr>
                  <td><label for="pam"><bean:message key="usercreate.jsp.pam"/></label></td>
                  <td>
                    <c:choose>
                      <c:when test="${displaypamcheckbox == 'true'}">
                      <html:checkbox property="usepam" onclick="$(\"[name='password-asterisk']\").toggle()" styleId="pam"/>
                      <label for="pam"><bean:message key="usercreate.jsp.pam.instructions"/></label> <br/>
                      <strong><span>
                          <bean:message key="usercreate.jsp.pam.instructions.note"/>
                      </span></strong>
                      </c:when>
                      <c:otherwise>
                        <bean:message key="usercreate.jsp.pam.reference"/>
                      </c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:if>
            </table>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="usercreate.accountInfo" /></h4>
        </div>
        <div class="panel-body">
          <table class="table">
            <tr>
              <td><label for="firstNames"><rhn:required-field key="usercreate.names"/>:</td></label>
              <td>
                <html:select styleClass="form-control margin-bottom-xs" property="prefix">
                  <html:options collection="availablePrefixes"
                    property="value"
                    labelProperty="label" />
                </html:select>

                <html:text property="firstNames" size="15" styleClass="form-control margin-bottom-xs" maxlength="${firstNameLength}" styleId="firstNames"/>
                <html:text property="lastName" size="15" styleClass="form-control margin-bottom-xs" maxlength="${lastNameLength}"/>
              </td>
            </tr>

            <tr>
               <td><label for="email"><rhn:required-field key="email"/>:</label></td>
               <td>
                   <html:text property="email" styleClass="form-control" maxlength="${emailLength}" styleId="email"/>
               </td>
            </tr>
            <html:hidden property="account_type" value="${account_type}" />
            <tr>
              <td colspan="2"><span class="required-form-field">*</span> - <bean:message key="usercreate.requiredField" /></td>
            </tr>
          </table>
        </div>
      </div>
    </div>
  </div>

<c:if test="${account_type == 'into_org'}">
  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="preferences.jsp.tz"/></h4>
    </div>
    <div class="panel-body">
      <p><bean:message key="preferences.jsp.datestimes"/></p>
      <div class="well well-sm">
        <bean:message key="preferences.jsp.displaytimesas"/>
        <select name="timezone">
          <c:forEach var="tz" items="${requestScope.timezones}">
            <c:if test="${tz.value == requestScope.default_tz}">
              <option value="${tz.value}" selected="selected">${tz.display}</option>
            </c:if>
            <c:if test="${tz.value != requestScope.default_tz}">
              <option value="${tz.value}">${tz.display}</option>
            </c:if>
          </c:forEach>
        </select>
      </div>
    </div>
  </div>
  <div class="panel panel-default" id="new-user-language">
    <div class="panel-heading">
      <h4><bean:message key="preferences.jsp.lang" /></h4>
    </div>
    <div class="panel-body">
      <p><bean:message key="preferences.jsp.langs" /></p>
      <div class="well well-sm">
        <c:set var="counter" value="0" />
        <table width="75%" cellpadding="0">
          <tr>
            <td width="50%">
              <input type="radio" name="preferredLocale" value="<c:out value="${noLocale.languageCode}" />"
              <c:if test="${noLocale.languageCode == currentLocale}">
                checked="checked"
              </c:if>/>
              <c:out value="${noLocale.localizedName}" />
              <br />
              <br />
            </td>
           </tr>
        <c:forEach var="item" items="${supportedLocales}">
          <c:if test="${counter == 0}">
            <tr>
          </c:if>
          <td width="50%">
            <input type="radio" name="preferredLocale" value="<c:out value="${item.key}" />"
              <c:if test="${item.key == currentLocale}">
                checked="checked"
              </c:if>/>
             <img src="<c:out value="${item.value.imageUri}" />" alt="<c:out value="${item.value.localizedName}" />" />&nbsp;(<c:out value="${item.value.localizedName}" />)
          </td>
          <c:if test="${counter == 1}">
            </tr>
          </c:if>
          <c:set var="counter" value="${counter + 1}" />
          <c:if test="${counter == 2}">
            <c:set var="counter" value="0" />
          </c:if>
        </c:forEach>

        <c:if test="${counter == 1}">
                </tr>
        </c:if>
        </table>
      </div>
    </div>
  </div>

</c:if>

<div class="text-center">
  <html:submit styleClass="btn btn-success">
    <bean:message key="usercreate.jsp.createlogin"/>
  </html:submit>
</div>


</html:form>

<%-- This makes sure that the asterisks toggle correctly. Before, they could get off
     if the user checked the usepam checkbox, submitted the form, and had errors. Then
     the form would start with the box checked but the asterisks visible.
--%>
<script language="javascript">
  var items = document.getElementsByName('password-asterisk');
  if (document.getElementById('pam')
         && document.getElementById('pam').checked == true) {
    for (var i = 0; i < items.length; i++) {
      items[i].style.display = "none";
    }
  }
  else {
    for (var i = 0; i < items.length; i++) {
      items[i].style.display = "";
    }
  }
</script>
</body>
</html>
