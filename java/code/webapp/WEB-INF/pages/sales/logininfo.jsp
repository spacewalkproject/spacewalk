<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
             imgAlt="system.common.infoAlt">
  <bean:message key="logininfo.jsp.logins"/>
</rhn:toolbar>

<p><bean:message key="logininfo.jsp.intro"/></p>
                
<h2><bean:message key="logininfo.jsp.tour.header"/></h2>
<p><bean:message key="logininfo.jsp.tour.info"
                 arg0="http://www.redhat.com/rhn/rhntour/"
                 arg1="http://www.redhat.com/rhn/"/></p>

<h2><bean:message key="logininfo.jsp.purchase.header"/></h2>
<p><bean:message key="logininfo.jsp.purchase.info"
                 arg0="http://www.redhat.com/store/"/></p>

<h2><bean:message key="logininfo.jsp.subscription.header"/></h2>

<p><bean:message key="logininfo.jsp.subscription.info"/></p>

<p><bean:message key="logininfo.jsp.subscription.para1"/></p>

<ul>

<li><bean:message key="logininfo.jsp.subscription.para2"
                  arg0="https://www.redhat.com/wapps/sso/rhn/lostPassword.html"/></li>

<li><bean:message key="logininfo.jsp.subscription.para3"
                  arg0="http://www.redhat.com/about/contact/dir/#custservice"/></li>

</ul>

<p><bean:message key="logininfo.jsp.subscription.para4"
                  arg0="http://www.redhat.com/rhel/details/howtoactivate/"
                  arg1="https://www.redhat.com/wapps/sso/rhn/lostPassword.html"/></p>

<h2><bean:message key="logininfo.jsp.campus.header"/></h2>
<p><bean:message key="logininfo.jsp.campus.info"/></p>
                 
</body>
</html>

