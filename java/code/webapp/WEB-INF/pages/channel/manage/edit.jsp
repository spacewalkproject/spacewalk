<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
             deletionUrl="/network/software/channels/manage/delete_confirm.pxt?cid=${param.cid}"
             deletionAcl="user_role(channel_admin); formvar_exists(cid)"
             deletionType="software.channel">
  <bean:message key="channel.edit.jsp.toolbar" arg0="${channel_name}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
                definition="/WEB-INF/nav/manage_channel.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />


<div>
   <html:form action="/channels/manage/Edit">
      
   <h2><bean:message key="channel.edit.jsp.basicchanneldetails"/></h2>
   <div class="page-summary">
      <bean:message key="channel.edit.jsp.introparagraph"/>
   </div>

   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.name"/><span class="required-form-field">*</span>:
         </th>
         <td class="small-form">
            <html:text property="name" maxlength="64" size="48"/>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.label"/><span class="required-form-field">*</span>:
         </th>
         <td class="small-form">
            <c:choose>
              <c:when test='${empty param.cid}'>
                 <html:text property="label" maxlength="128" size="32" />
              </c:when>
              <c:otherwise>
                 <c:out value="${channel_label}"/>
                 <html:hidden property="label" value="${channel_label}" />
              </c:otherwise>
            </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.parent"/>:
         </th>
         <td class="small-form">
          <c:choose>
            <c:when test='${empty param.cid}'>
                <html:select property="parent">
                    <html:options collection="parentChannels"
                                  property="value"
                                  labelProperty="label" />
                </html:select>
            </c:when>
            <c:otherwise>
               <c:out value="${parent_name}"/>
               <html:hidden property="parent" value="${parent_id}"/>
            </c:otherwise>
          </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.parentarch"/>:
         </th>
         <td class="small-form">
          <c:choose>
            <c:when test='${empty param.cid}'>
                <html:select property="arch">
                    <html:options collection="channelArches"
                                  property="value"
                                  labelProperty="label" />
                </html:select>
            </c:when>
            <c:otherwise>
               <c:out value="${channel_arch}"/>
               <html:hidden property="arch" value="${channel_arch_label}" />
               <html:hidden property="arch_name" value="${channel_arch}" />
            </c:otherwise>
          </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.summary"/><span class="required-form-field">*</span>:
         </th>
         <td class="small-form">
            <html:text property="summary" maxlength="500" size="40" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.description"/>:
         </th>
         <td class="small-form">
            <html:textarea property="description" cols="40" rows="6"/>
         </td>
      </tr>
   </table>

   <h2><bean:message key="channel.edit.jsp.contactsupportinfo"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.maintainername"/>:
         </th>
         <td class="small-form">
            <html:text property="maintainer_name" maxlength="128" size="40" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.maintainercontactinfo"/>:
         </th>
         <td class="small-form">
            <table>
            <tr>
            <td><bean:message key="channel.edit.jsp.emailaddress"/>:</td>
            <td><html:text property="maintainer_email" size="20" /></td>
            </tr><tr>
            <td><bean:message key="channel.edit.jsp.phonenumber"/>:</td>
            <td><html:text property="maintainer_phone" size="20" /></td>
            </tr>
            </table>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.supportpolicy"/>:
         </th>
         <td class="small-form">
            <html:textarea property="support_policy" cols="40" rows="6" />
         </td>
      </tr>
   </table>
   <h2><bean:message key="channel.edit.jsp.channelaccesscontrol"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.perusersub"/>:
         </th>
         <td class="small-form">
            <table>
            <tr>
            <td><html:radio property="per_user_subscriptions" value="all" /></td>
            <td><bean:message key="channel.edit.jsp.allusers"/></td>
            </tr><tr>
            <td><html:radio property="per_user_subscriptions" value="selected" /></td>
            <rhn-require 
            <td><bean:message key="channel.edit.jsp.selectedusers"/></td>
            </tr>
            </table>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.orgsharing"/>
         </th>
         <td class="small-form">
            <table>
            <tr>
            <td><html:radio property="org_sharing" value="private" /></td>
            <td><bean:message key="channel.edit.jsp.private"
                      arg0="/rhn/multiorg/Organizations.do"/></td>
            </tr><tr>
            <td><html:radio property="org_sharing" value="protected" /></td>
            <td><bean:message key="channel.edit.jsp.protected"
                      arg0="/rhn/multiorg/Organizations.do"/>
                      </td>
            </tr><tr>
            <td><html:radio property="org_sharing" value="public" /></td>
            <td><bean:message key="channel.edit.jsp.public"
                      arg0="/rhn/multiorg/Organizations.do"/></td>
            </tr>
            </table>
         </td>
      </tr>
   </table>
   <h2><bean:message key="channel.edit.jsp.security.gpg"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyurl"/>:
         </th>
         <td class="small-form">
            <html:text property="gpg_key_url" maxlength="256" size="40" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyid"/>:
         </th>
         <td class="small-form">
            <html:text property="gpg_key_id" maxlength="8" size="8"/><br />Ex: DB42A60E
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyfingerprint"/>:
         </th>
         <td class="small-form">
            <html:text property="gpg_key_fingerprint" maxlength="50" size="60"/><br />
            Ex: CA20 8686 2BD6 9DFC 65F6  ECC4 2191 80CD DB42 A60E
         </td>
      </tr>
   </table>
   <div align="right">
      <hr />
      <c:choose>
         <c:when test='${empty param.cid}'>
         <html:submit property="create_button">
            <bean:message key="channel.edit.jsp.createchannel"/>
         </html:submit>
         </c:when>
         <c:otherwise>
         <html:submit property="edit_button">
            <bean:message key="channel.edit.jsp.editchannel"/>
         </html:submit>
         </c:otherwise>
      </c:choose>
   </div>
   <html:hidden property="submitted" value="true" />
   <c:if test='${not empty param.cid}'>
       <html:hidden property="cid" value="${param.cid}" />
   </c:if>
</html:form>
</div>

</body>
</html>

