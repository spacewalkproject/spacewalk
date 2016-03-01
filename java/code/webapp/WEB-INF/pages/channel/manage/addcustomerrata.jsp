<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
<BR>

<rl:listset name="errataSet">
<rhn:csrf />
<rhn:hidden name="cid" value="${cid}">



<table class="details" width="80%">
        <tr><bean:message key="channel.manage.errata.custommsg"/><br /><br /></tr>

         <tr>
                <th>Package Association:</th>
                <td>
                           <input type="checkbox" name="assoc_checked"   <c:if test="${assoc_checked}">checked </c:if>  >
                           <bean:message key="channel.manage.errata.packageassocmsg" />
                 </td>
   </tr>

                <c:if test="${selected_channel != null}">
                        <rhn:hidden name="selected_channel_old"  value="${selected_channel}">
                </c:if>
                <c:if test="${channel_list != null}">

                          <tr> <th width="10%">Channel:</th><td width="40%">
                          <select name="selected_channel">
                                    <option value="" >All Custom Channels</option>
                                    <optgroup>
                                        <c:forEach var="option" items="${channel_list}">
                                                <c:choose>
                                                        <c:when test="${option.baseChannel}">
                                                            </optgroup>
                                                                <option value="${option.id}"  <c:if test="${option.selected eq true}">selected = "selected"</c:if>    >${option.name}   </option>
                                                                <optgroup>
                                                        </c:when>
                                                        <c:otherwise>
                                                                <option value="${option.id}"   <c:if test="${option.selected eq true}">selected = "selected"</c:if> >${option.name}</option>
                                                        </c:otherwise>
                                                </c:choose>
                                        </c:forEach>
                                        </optgroup>
                          </select>

                          </td>
                                          <td>
                                                          <input class="btn btn-default" type="submit" name="dispatch"  value="<bean:message key='frontend.actions.channels.manager.add.viewErrata'/>">
                                          </td>
                             </tr>
                  </c:if>


  </table>
  <br /><br />

   <c:choose>
                <c:when test="${pageList != null}">
                    <%@ include file="/WEB-INF/pages/common/fragments/errata/selectableerratalist.jspf" %>
  </c:when>
</c:choose>
                <div class="text-right">
                    <hr />
                    <input class="btn btn-default" type="submit" name="dispatch"  value="<bean:message key='frontend.actions.channels.manager.add.submit'/>" ${empty pageList ? 'disabled' : ''} >
                </div>
     <rhn:submitted/>
</rl:listset>

</body>
</html>

