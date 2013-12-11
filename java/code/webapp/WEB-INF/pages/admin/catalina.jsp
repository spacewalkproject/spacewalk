<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>

<head>
<script language="javascript" type="text/javascript" src="/editarea/edit_area_full.js"></script>
<script language="javascript" type="text/javascript">
editAreaLoader.init({
        id : "contents"
        ,allow_toggle: true
        ,allow_resize: "both"
        ,display: "later"
        ,toolbar: "search, go_to_line, |, help"
});
</script>
</head>

<body>

   <rhn:require acl="user_role(satellite_admin)"/>
   <rhn:toolbar base="h1" icon="header-list">Tomcat</rhn:toolbar>
   <form action="/rhn/admin/Catalina.do">
     <rhn:csrf />
     <div class="panel panel-default">
       <div class="panel-heading">
         <bean:message key="catalina.jsp.show"/>
       </div>
       <div class="panel-body">
        <textarea name="contents" rows="24" class="form-control" id="contents">${contents}</textarea>
       </div>
     </div>
     <rhn:submitted/>
   </form>
 </body>
</html>
