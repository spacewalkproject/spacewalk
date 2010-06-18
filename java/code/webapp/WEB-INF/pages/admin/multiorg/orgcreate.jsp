<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>

<script language="javascript" src="/javascript/display.js"></script>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
  <bean:message key="orgcreate.jsp.title"/>
</rhn:toolbar>

<div>
    <html:form action="/admin/multiorg/OrgCreate">
        <html:hidden property="submitted" value="true"/>
        <h2><bean:message key="orgdetails.jsp.header"/></h2>
		<table class="details" align="center">
		  <tr>
        <th width="25%"><label for="orgName"><rhn:required-field key="org.name.jsp"/>:</label></th>
		    <td><html:text property="orgName" maxlength="128" size="40" styleId="orgName" />
		        <br>
                <span class="small-text"><strong><bean:message key="tip" /></strong>
                  <bean:message key="org.name.length.tip" /></span>
		    </td>    
		  </tr>
		  </table>
        <h2><bean:message key="orgcreate.jsp.adminheader"/></h2>
        <table class="details" align="center">
        <p>
            <bean:message key="orgcreate.header2"/>
        </p>
		    <tr>
		      <th><label for="login"><rhn:required-field key="desiredlogin"/>:</label></th>
		      <td>
		        <html:text property="login" size="15" maxlength="45" styleId="login" />
		        <br>
		        <span class="small-text"><strong><bean:message key="tip" /></strong>
		          <bean:message key="org.login.tip" arg0="${rhn:getConfig('web.min_user_len')}" /><br>"
		          <bean:message key="org.login.examples" /></span>
		          
		      </td>
		    </tr>
		    <tr>
		      <th><label for="desiredpass"><bean:message key="desiredpass" />
		       <span name="password-asterisk" class="required-form-field">*</span>:</label></th>
		      <td>
		        <html:password property="desiredpassword" size="15" maxlength="32" styleId="desiredpass" />
		      </td>
		    </tr>
		    <tr>
		      <th><label for="confirmpass"><bean:message key="confirmpass" />
		      <span name="password-asterisk" class="required-form-field">*</span>:</label></th>
		      <td>
		        <html:password property="desiredpasswordConfirm" size="15" maxlength="32" styleId="confirmpass"/>
		      </td>
		    </tr>
      <tr>
        <th><label for="pam"><bean:message key="usercreate.jsp.pam"/></label></th>
        <td>
          <c:choose>
            <c:when test="${displaypamcheckbox == 'true'}">
            <html:checkbox property="usepam" onclick="toggleVisibilityByName('password-asterisk')" styleId="pam"/>
            <label for="pam"><bean:message key="usercreate.jsp.pam.instructions"/></label> <br/>
            <strong><span style="font-size: 10px">
                <bean:message key="usercreate.jsp.pam.instructions.note"/>
            </span></strong>
            </c:when>
            <c:otherwise>
              <bean:message key="usercreate.jsp.pam.reference"/>
            </c:otherwise>
          </c:choose>
        </td>
      </tr>		    
		    <tr>
              <th><label for="email"><rhn:required-field key="email"/>:</label></th>
              <td>
                <html:text property="email" size="45" maxlength="128" styleId="email" />
              </td>
            </tr>
		    <tr>
              <th><label for="firstNames"><rhn:required-field key="firstNames"/>:</label></th>
               
              <td>
              <html:select property="prefix">
               <html:options collection="availablePrefixes"
                               property="value"
                          labelProperty="label" />
               </html:select>
                <html:text property="firstNames" size="45" maxlength="128" styleId="firstNames"/>
              </td>
            </tr>
		    <tr>
              <th><label for="lastName"><rhn:required-field key="lastName"/>:</label></th>
              <td>
                <html:text property="lastName" size="45" maxlength="128" styleId="lastName"/>
              </td>
            </tr>
            <tr>
              <td style="border: 0; text-align: center" colspan="2"><span class="required-form-field">*</span> - <bean:message key="usercreate.requiredField" /></td>
            </tr>
          </table>
 <div align="right">
   
   <html:submit>
   <bean:message key="orgcreate.jsp.submit"/>
   </html:submit>
 </div>

          
    </html:form>
</div>
<%-- This makes sure that the asterisks toggle correctly. Before, they could get off 
     if the user checked the usepam checkbox, submitted the form, and had errors. Then
     the form would start with the box checked but the asterisks visible.
--%>
<script language="javascript">
  var items = document.getElementsByName('password-asterisk');
  if (document.orgCreateForm.usepam.checked == true) {
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

