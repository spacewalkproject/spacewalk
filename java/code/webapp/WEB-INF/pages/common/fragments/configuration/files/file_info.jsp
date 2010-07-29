<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<c:set value="${requestScope[param.configchan]}" var="mychan"/>
<c:set value="${requestScope[param.configfile]}" var="myfile"/>
<c:set value="${requestScope[param.configrev]}" var="myrev"/>

<div class="filename">
  ${myfile.configFileName.path}
</div>
<table>
  <tr>
    <td><strong><bean:message key="diff.jsp.version" /></strong></td>
    <td>
      <a href="/rhn/configuration/file/FileDetails.do?cfid=${myfile.id}&amp;crid=${myrev.id}">
        <bean:message key="diff.jsp.revision" arg0="${myrev.revision}" />
      </a>
    </td>
  </tr>
  <tr>
    <td><strong><bean:message key="diff.jsp.from" /></strong></td>
    <td>
      <a href="/rhn/configuration/ChannelOverview.do?ccid=${mychan.id}">
      <c:choose>
        <c:when test="${mychan.configChannelType.label == 'server_import'}">
          <img alt='<bean:message key="config.common.sandboxAlt" />'
               src="/img/rhn-listicon-sandbox.png" />
        </c:when>
        <c:when test="${mychan.configChannelType.label == 'local_override'}">
          <img alt='<bean:message key="config.common.localAlt" />'
               src="/img/rhn-listicon-system.gif" />
        </c:when>
        <c:otherwise>
          <img alt='<bean:message key="config.common.globalAlt" />'
               src="/img/rhn-listicon-channel.gif" />
        </c:otherwise>
      </c:choose>
      ${mychan.name}
      </a>
    </td>
  </tr>
  <c:if test="${difftype == 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.filetype" /></strong></td>
      <td>
        <c:choose>
          <c:when test="${myrev.directory}">
            <bean:message key="diff.jsp.dir" />
          </c:when>
          <c:when test="${myrev.configContent.binary}">
            <bean:message key="diff.jsp.bin" />
          </c:when>
          <c:otherwise>
            <bean:message key="diff.jsp.txt" />
          </c:otherwise>
        </c:choose>
      </td>
    </tr>
  </c:if>
  <c:if test="${diffmode == 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.filemode" /></strong></td>
      <td>${myrev.configInfo.filemode}</td>
    </tr>
  </c:if>
  <c:if test="${diffuser == 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.username" /></strong></td>
      <td>${myrev.configInfo.username}</td>
    </tr>
  </c:if>
  <c:if test="${diffgroup == 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.groupname" /></strong></td>
      <td>${myrev.configInfo.groupname}</td>
    </tr>
  </c:if>
  <c:if test="${diffselinux == 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.selinux" /></strong></td>
      <td>${myrev.configInfo.selinuxCtx}</td>
    </tr>
  </c:if>  

  <c:if test="${difftargetpath== 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.targetpath" /></strong></td>
      <td>${myrev.configInfo.targetFileName.path}</td>
    </tr>
  </c:if>
  
  <c:if test="${diffdelim == 'true'}">
    <tr>
      <td><strong><bean:message key="diff.jsp.startDelim" /></strong></td>
      <td>${myrev.delimStart}</td>
    </tr>
    <tr>
      <td><strong><bean:message key="diff.jsp.endDelim" /></strong></td>
      <td>${myrev.delimEnd}</td>
    </tr>
  </c:if>
</table>
<hr />