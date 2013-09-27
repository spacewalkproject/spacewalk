<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<head>
    <%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>

<html:html>
    <body>
        <c:choose>
            <c:when test = "${not empty requestScope.create_mode}">
                <rhn:toolbar base="h1" img="/img/rhn-icon-info.gif" imgAlt="info.alt.img">
                    <bean:message key="snippetcreate.jsp.toolbar"/>
                </rhn:toolbar>
                <h2><bean:message key="snippetcreate.jsp.header2"/></h2>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1"
                             img="/img/rhn-icon-info.gif"
                             imgAlt="info.alt.img"
                             deletionUrl="CobblerSnippetDelete.do?name=${cobblerSnippetsForm.map.name}"
                             deletionType="snippets">
                    <c:out value="${requestScope.snippet.displayName}"/>
                </rhn:toolbar>
                <h2><bean:message key="snippetdetails.jsp.header2"/></h2>
            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${empty requestScope.create_mode}">
                <c:set var="url" value ="/kickstart/cobbler/CobblerSnippetEdit"/>
            </c:when>
            <c:otherwise>
                <c:set var="url" value ="/kickstart/cobbler/CobblerSnippetCreate"/>
            </c:otherwise>
        </c:choose>

    <html:form action="${url}" styleClass="form-horizontal">
    <rhn:csrf />
    <rhn:submitted/>

    <div class="form-group">
        <label class="col-lg-3 control-label">
            <rhn:required-field key = "cobbler.snippet.name"/>
        </label>
        <div class="col-lg-6">
            <html:text property="name" styleClass="form-control"/>
            <span class="help-block"><rhn:tooltip key="snippetcreate.jsp.tip1"/></span>
            <c:if  test = "${empty requestScope.create_mode}">
                <span class="help-block"><rhn:warning key="snippetcreate.jsp.warning.tip"/></span>
                <html:hidden property="oldName"/>
            </c:if>
        </div>
     </div>

     <c:if  test = "${empty requestScope.create_mode}">
         <div class="form-group">
             <label class="col-lg-3 control-label">
                 <bean:message key="cobbler.snippet.path"/>:
             </label>
             <div class="col-lg-6">
                 <p><c:out value="${requestScope.snippet.displayPath}"/></p>
                 <span class="help-block"><rhn:tooltip key="cobbler.snippet.path.tip"/></span>
             </div>
         </div>

         <div class="form-group">
             <label class="col-lg-3 control-label">
                 <bean:message key="cobbler.snippet.macro"/>:
             </label>
             <div class="col-lg-6">
                 <p><c:out value="${requestScope.snippet.fragment}"/></p>
                 <span class="help-block"><rhn:tooltip key="cobbler.snippet.copy-paste-snippet-tip"/></span>
             </div>
         </div>
     </c:if>

     <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="cobbler.snippet.type"/>:
        </label>
        <div class="col-lg-6">
            <bean:message key="Custom"/>
            <span class="help-block">
                <rhn:tooltip>
                    <bean:message key="cobbler.snippet.custom.tip"
                                  arg0="${requestScope.org}"/>
                </rhn:tooltip>
            </span>
        </div>
     </div>

     <h2><bean:message key="snippetcreate.jsp.contents.header"/></h2>

     <div class="form-group">
         <label class="col-lg-3 control-label">
             <rhn:required-field key="snippetcreate.jsp.contents"/>
         </label>
         <div class="col-lg-6">
             <html:textarea property="contents" rows="24" cols="80"
                            styleId="contents" styleClass="form-control"/>
         </div>
     </div>

     <div class="form-group">
         <div class="col-lg-offset-3 col-lg-6">
             <html:submit styleClass="btn btn-success">
                 <c:choose>
                     <c:when test = "${empty requestScope.create_mode}">
                         <bean:message key="snippetupdate.jsp.submit"/>
                     </c:when>
                     <c:otherwise>
                         <bean:message key="snippetcreate.jsp.submit"/>
                     </c:otherwise>
                 </c:choose>
             </html:submit>
         </div>
     </div>
     </html:form>
     </body>
</html:html>
