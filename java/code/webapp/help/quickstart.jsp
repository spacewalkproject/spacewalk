<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<h1><img src="/img/rhn-icon-info.gif" alt="information" />Spacewalk Quick Start Guide</h1>
                                                                                                              
<p>Spacewalk is a powerful and flexible tool for the administration of large-scale networks of Red Hat Linux systems -- but it's also well-suited for the simplest system administration tasks as well. This guide will get you started.</p>
                                                                                                              
<br />
                                                                                                              
<h2>Registering Your Systems</h2>
                                                                                                             
<p>If we don't know anything about your systems, we can't help you maintain them properly. The <strong>RHN Registration Tool</strong> is how we learn about your systems.</p>
                                                                                                              
<p>The Spacewalk Registration Client can be found in your Applications Menu, or it can be run from command line. Within the Applications Menu, look for System Tools &rArr; Spacewalk. At the command line, on Red Hat Enterprise Linux 3, run <code>up2date --register</code> as root. If you use Red Hat Enterprise Linux 2.1, 4 or later run <code>/usr/sbin/rhn_register </code> as root. Use your RHN account information when registering your system, or create a new RHN account during the registration process if you do not already have one.</p>
                                                                                                              
<p>Once your system has been registered, you may sign in to the RHN web site and see all that RHN knows about that system by clicking on the <strong><a href="/rhn/systems/Overview.do">Systems</a></strong> tab at the top of the page, and then selecting the individual system.</p>
                                                                                                              
<p>You may register as many systems as you wish. To use Spacewalk to its fullest, however, you must <strong>entitle</strong> your systems to receive updates directly from RHN.  Any system profiled will be automatically entitled, as long as you have free entitlements.</p>
                                                                                                              
<p>You may register a system at any time.  However, you must purchase at minimum an Update entitlement for each registered system before you can use RHN services for those systems.  Once purchased, entitlements may be applied to and removed from systems at any time you choose.</p>
                                                                                                              
<p>Customers who purchase entitlements also receive the additional benefit of downloading Red Hat Linux ISO images directly from the high-bandwidth Spacewalk servers.</p>
                                                                                                              
<br />
                                                                                                              
<h2>Applying Errata Updates</h2>
                                                                                                             
<p>Once you've registered a system with Spacewalk and entitled it for service, you will receive occasional <strong>errata notifications</strong>.  These describe available updates for your Red Hat Linux systems. To apply these errata, click on the
<strong><a href="/rhn/systems/Overview.do">Systems</a></strong> 
tab at the top of the page. From the System List, click on a system's name, and then from that "System Detail" view, select the "Errata" tab. There you will find a list of all errata that apply to that particular system; simply select the errata you want to apply and click on the "Update For Selected Errata" button. The errata update will then be scheduled for update. (Remember, your system must be entitled to apply errata updates. If your system is not entitled, the "Errata" tab will not even appear.)</p>
                                                                                                              
<br />
                                                                                                              
<h2>One Click Updates</h2>
                                                                                                              
<p>Sometimes it can be time-consuming to keep track of all of the available software updates. Spacewalk makes it simple to update your systems with the latest and greatest, simply by clicking one button.</p>
                                                                                                              
<p>From the <strong><a href="/rhn/systems/Overview.do">Systems</a></strong> tab, click on a system name. If the system is entitled, and if it requires updates, you will immediately see a link labeled "update now". Selecting that option will schedule an update of every outdated package on the system.</p>
                                                                                                              
<br />
                                                                                                              
<h2>Troubleshooting</h2>
                                                                                                              
<p>In order to use Spacewalk, your Red Hat Linux system must be set up properly to receive updates. Generally, a system will be properly configured by default. If you have problems, though, consult the <a href="/help/faq.pxt"><strong>Spacewalk FAQ</strong></a> for more detailed information.</p>
                                                                                                              



</body>
</html>
