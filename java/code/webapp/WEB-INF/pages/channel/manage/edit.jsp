<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
             deletionUrl="/rhn/channels/manage/Delete.do?cid=${param.cid}"
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
            <label for="name"><rhn:required-field key="channel.edit.jsp.name"/>:</label>
         </th>
         <td class="small-form">
            <html:text property="name" maxlength="256" size="48" styleId="name"/>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="label"><rhn:required-field key="channel.edit.jsp.label"/>:</label>
         </th>
         <td class="small-form">
            <c:choose>
              <c:when test='${empty param.cid}'>
                 <html:text property="label" maxlength="128" size="32" styleId="label" />
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
            <label for="parent"><bean:message key="channel.edit.jsp.parent"/>:</label>
         </th>
         <td class="small-form">
          <c:choose>
            <c:when test='${empty param.cid}'>
                <html:select property="parent" styleId="parent">
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
            <label for="parentarch"><bean:message key="channel.edit.jsp.parentarch"/>:</label>
         </th>
         <td class="small-form">
          <c:choose>
            <c:when test='${empty param.cid}'>
                <html:select property="arch" styleId="parentarch">
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
            <label for="checksum"><bean:message key="channel.edit.jsp.checksum"/>:</label>
         </th>
         <td class="small-form">
            <html:select property="checksum">
                <html:options collection="checksums"
                              property="label"
                              labelProperty="label" />
            </html:select><br/>
            <span class="small-text"><bean:message key="channel.edit.jsp.checksumtip"/></span>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="summary"><rhn:required-field key="channel.edit.jsp.summary"/>:</label>
         </th>
         <td class="small-form">
            <html:text property="summary" maxlength="500" size="40" styleId="summary" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="description"><bean:message key="channel.edit.jsp.description"/>:</label>
         </th>
         <td class="small-form">
            <html:textarea property="description" cols="40" rows="6" styleId="description"/>
         </td>
      </tr>
   </table>
   
   <h2><bean:message key="channel.edit.jsp.contactsupportinfo"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <label for="maintainer_name"><bean:message key="channel.edit.jsp.maintainername"/>:</label>
         </th>
         <td class="small-form">
            <html:text property="maintainer_name" maxlength="128" size="40" styleId="maintainer_name"/>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.maintainercontactinfo"/>:
         </th>
         <td class="small-form">
            <table>
            <tr>
            <td><label for="maintainer_email"><bean:message key="channel.edit.jsp.emailaddress"/>:</label></td>
            <td><html:text property="maintainer_email" size="20" styleId="maintainer_email"/></td>
            </tr><tr>
            <td><label for="maintainer_phone"><bean:message key="channel.edit.jsp.phonenumber"/>:</label></td>
            <td><html:text property="maintainer_phone" size="20" styleId="maintainer_phone"/></td>
            </tr>
            </table>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="support_policy"><bean:message key="channel.edit.jsp.supportpolicy"/>:</label>
         </th>
         <td class="small-form">
            <html:textarea property="support_policy" cols="40" rows="6" styleId="support_policy"/>
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
            <td><html:radio property="per_user_subscriptions" value="all" styleId="allusers" /></td>
            <td><label for="allusers"><bean:message key="channel.edit.jsp.allusers"/></label></td>
            </tr><tr>
            <td><html:radio property="per_user_subscriptions" value="selected" styleId="selectedusers" /></td>
            <td><label for="selectedusers"><bean:message key="channel.edit.jsp.selectedusers"/></label></td>
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
            <td><html:radio property="org_sharing" value="private" styleId="private"/></td>
            <td><label for="private"><bean:message key="channel.edit.jsp.private"
                      arg0="/rhn/multiorg/Organizations.do"/></label></td>
            </tr><tr>
            <td><html:radio property="org_sharing" value="protected" styleId="protected" /></td>
            <td><label for="protected"><bean:message key="channel.edit.jsp.protected"
                      arg0="/rhn/multiorg/Organizations.do"/></label>
                      </td>
            </tr><tr>
            <td><html:radio property="org_sharing" value="public" styleId="public"/></td>
            <td><label for="public"><bean:message key="channel.edit.jsp.public"
                      arg0="/rhn/multiorg/Organizations.do"/></label></td>
            </tr>
            </table>
         </td>
      </tr>
   </table>
   <h2><bean:message key="channel.edit.jsp.security.gpg"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <label for="gpgkeyurl"><bean:message key="channel.edit.jsp.gpgkeyurl"/>:</label>
         </th>
         <td class="small-form">
            <html:text property="gpg_key_url" maxlength="256" size="40" styleId="gpgkeyurl"/>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="gpgkeyid"><bean:message key="channel.edit.jsp.gpgkeyid"/>:</label>
         </th>
         <td class="small-form">
            <html:text property="gpg_key_id" maxlength="8" size="8" styleId="gpgkeyid"/><br />Ex: DB42A60E
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="gpgkeyfingerprint"><bean:message key="channel.edit.jsp.gpgkeyfingerprint"/>:</label>
         </th>
         <td class="small-form">
            <html:text property="gpg_key_fingerprint" maxlength="50" size="60" styleId="gpgkeyfingerprint"/><br />
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

