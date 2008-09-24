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

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif">
  <bean:message key="channel.edit.jsp.toolbar"/>
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
            <bean:message key="channel.edit.jsp.name"/>:
         </th>
         <td class="small-form">
            <html:text property="name" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.label"/>:
         </th>
         <td class="small-form">
            <c:choose>
              <c:when test='${empty param.cid}'>
                 <html:text property="label" />
              </c:when>
              <c:otherwise>
                 <c:out value="${channel.label}"/>
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
               <c:out value="${channel.name}"/>
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
               <c:out value="${channel.arch}"/>
            </c:otherwise>
          </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.summary"/>:
         </th>
         <td class="small-form">
            <html:text property="summary" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.description"/>:
         </th>
         <td class="small-form">
            <html:text property="description" />
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
            <html:text property="maintainer_name" />
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
            <td><html:text property="maintainer_email" /></td>
            </tr><tr>
            <td><bean:message key="channel.edit.jsp.phonenumber"/>:</td>
            <td><html:text property="maintainer_phone" /></td>
            </tr>
            </table>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.supportpolicy"/>:
         </th>
         <td class="small-form">
            <html:text property="support_policy" />
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
            <html:radio property="per_user_subscriptions" value="true" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.orgsharing"/>
         </th>
         <td class="small-form">
            <html:radio property="org_sharing" value="true"  />
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
            <html:text property="gpg_key_url" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyid"/>:
         </th>
         <td class="small-form">
            <html:text property="gpg_key_id" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyfingerprint"/>:
         </th>
         <td class="small-form">
            <html:text property="gpg_key_fingerprint" />
         </td>
      </tr>
   </table>
   <div align="right">
      <hr />
      <html:submit>
         <bean:message key="channel.edit.jsp.createchannel"/>
      </html:submit>
   </div>
   <html:hidden property="cid" value="${requestScope.cid}" />
   <html:hidden property="submitted" value="true" />
</html:form>
</div>

</body>
</html>

