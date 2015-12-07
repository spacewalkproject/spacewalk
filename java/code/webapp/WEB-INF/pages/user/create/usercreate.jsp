<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>

  <rhn:toolbar base="h1" icon="header-user" imgAlt="user.common.userAlt"
       helpUrl="">
  <bean:message key="usercreate.toolbar" />
  </rhn:toolbar>

<html:form action="/newlogin/CreateUserSubmit" styleClass="form-horizontal">

  <rhn:csrf />
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="usercreate.login" /></h4>
        </div>
        <div class="panel-body">
              <div class="form-group">
                <label class="col-sm-3 control-label" for="login"><rhn:required-field key="desiredlogin"/>:</label>
                <div class="col-sm-6">
                  <html:text property="login" styleClass="form-control" maxlength="${loginLength}" styleId="loginname"/>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-3 control-label" for="desiredpass"><bean:message key="desiredpass" /><span name="password-asterisk"
                      class="required-form-field">*</span>:</label>
                <div class="col-sm-6">
                  <div id="desiredpassword-input-group" class="input-group">
                      <html:password property="desiredpassword" styleClass="form-control" size="15" maxlength="${passwordLength}"/>
                      <span class="input-group-addon">
                          <i class="fa fa-times-circle text-danger fa-1-5x" id="desiredtick"></i>
                      </span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="col-sm-3 control-label" for="confirmpass"><bean:message key="confirmpass" /><span name="password-asterisk"
                      class="required-form-field">*</span>:</label>
                <div class="col-sm-6">
                  <div class="input-group">
                      <html:password styleClass="form-control" property="desiredpasswordConfirm" onkeyup="updateTickIcon()" size="15" maxlength="${passwordLength}" styleId="confirmpass"/>
                      <span class="input-group-addon">
                          <i class="fa fa-times-circle text-danger fa-1-5x" id="confirmtick"></i>
                      </span>
                  </div>
                </div>
              </div>
              <script type="text/javascript" src="/javascript/pwstrength-bootstrap-1.0.2.js"></script>
              <script type="text/javascript" src="/javascript/spacewalk-pwstrength-handler.js"></script>
              <script type="text/javascript">
function toggleAsterisk() {
  $("[name='password-asterisk']").toggle()
}
              </script>
              <div class="form-group">
                <label class="col-sm-3 control-label"><bean:message key="help.credentials.jsp.passwordstrength"/>:</label>
                <div class="col-sm-6">
                    <div id="pwstrenghtfield">
                      <!-- progress-bar will attach to this container -->
                    </div>
                </div>
              </div>
              <c:if test="${displaypam == 'true'}">
                <div class="form-group">
                  <label class="col-sm-3 control-label" for="pam"><bean:message key="usercreate.jsp.pam"/></label>
                  <div class="col-sm-6">
                    <c:choose>
                      <c:when test="${displaypamcheckbox == 'true'}">
                      <html:checkbox property="usepam" onclick="toggleAsterisk()" styleId="pam"/>
                      <label for="pam"><bean:message key="usercreate.jsp.pam.instructions"/></label> <br/>
                      <strong><span>
                          <bean:message key="usercreate.jsp.pam.instructions.note"/>
                      </span></strong>
                      </c:when>
                      <c:otherwise>
                        <bean:message key="usercreate.jsp.pam.reference"/>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </c:if>
        </div>
      </div>
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="usercreate.accountInfo" /></h4>
        </div>
        <div class="panel-body">
            <div class="form-group">
              <label class="col-sm-3 control-label" for="firstNames"><rhn:required-field key="usercreate.names"/>:</label>
              <div class="col-sm-6">
                <html:select styleClass="form-control margin-bottom-xs box-small" property="prefix">
                  <html:options collection="availablePrefixes"
                    property="value"
                    labelProperty="label" />
                </html:select>

                <html:text property="firstNames" size="15" styleClass="form-control margin-bottom-xs box-large" maxlength="${firstNameLength}" styleId="firstNames"/>
                <html:text property="lastName" size="15" styleClass="form-control margin-bottom-xs box-large" maxlength="${lastNameLength}"/>
              </div>
            </div>

            <div class="form-group">
               <label class="col-sm-3 control-label" for="email"><rhn:required-field key="email"/>:</label>
               <div class="col-sm-6">
                   <html:text property="email" styleClass="form-control" maxlength="${emailLength}" styleId="email"/>
               </div>
            </div>
            <div class="form-group">
               <label class="col-sm-3 control-label" for="readonly"><bean:message key="usercreate.jsp.api.readOnly" /></label>
               <div class="col-sm-6">
                   <html:checkbox property="readonly" />
                   <br/><small><bean:message key="usercreate.jsp.api.readOnlyHelp"/></small>
               </div>
            </div>
            <hr />
            <p>
              <span class="required-form-field">*</span> - <bean:message key="usercreate.requiredField" />
            </p>
        </div>
      </div>

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="preferences.jsp.tz"/></h4>
    </div>
    <div class="panel-body">
      <p><bean:message key="preferences.jsp.datestimes"/></p>
      <div class="well well-sm">
        <bean:message key="preferences.jsp.displaytimesas"/>
        <select name="timezone" class="form-control">
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
          <div class="form-group">
            <div class="col-sm-6">
              <input type="radio" name="preferredLocale" value="<c:out value="${noLocale.languageCode}" />"
              <c:if test="${noLocale.languageCode == currentLocale}">
                checked="checked"
              </c:if>/>
              <c:out value="${noLocale.localizedName}" />
              <br />
              <br />
            </div>
          </div>
        <c:forEach var="item" items="${supportedLocales}">
          <c:if test="${counter == 0}">
            <div class="form-group">
          </c:if>
          <div class="col-sm-6">
            <input type="radio" name="preferredLocale" value="<c:out value="${item.key}" />"
              <c:if test="${item.key == currentLocale}">
                checked="checked"
              </c:if>/>
            <span class="text-info"><strong><c:out value="${item.value.localizedName}" /></strong></span>
          </div>
          <c:if test="${counter == 1}">
            </div>
          </c:if>
          <c:set var="counter" value="${counter + 1}" />
          <c:if test="${counter == 2}">
            <c:set var="counter" value="0" />
          </c:if>
        </c:forEach>

        <c:if test="${counter == 1}">
                </div>
        </c:if>
      </div>
    </div>
  </div>


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
