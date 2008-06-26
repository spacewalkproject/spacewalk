<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:py="http://purl.org/kid/ns#">
<head>
<title>RHN Usage Statistics</title>
<?php
include("../Templates/dochead.php");
?>

</head>
<body>

  <?php
  include("../Templates/clsheader.php");
  ?>

    <p>
    This web site is automatically generated to aid in billing out NCSU's
    share of the Red Hat contract.  The Group Name is the same as the
    groups in the Red Hat Network which should very closely relate to
    a College or Department at NCSU.  If you have any questions, please
    contact the webmaster linked at the bottom of the page.
    </p>
    
    <p>Generated On: <b py:content="date">4th of Juvember</b></p>
    <p>Total Licenses Used: <b py:content="total">This is fake</b></p>
    <p>Total Realm Linux Clients: <b py:content="totalrl">Even faker</b></p>
    
<table border="1">
  <tr>
    <th>Group Name</th>
    <th>Licenses Used</th>
    <th>Realm Linux Machines</th>
    <th>Percentage</th>
  </tr>

  <div py:for="foo in table">
    <tr>
      <td py:content="foo['name']">College of Underwater Basket Weaving</td>
      <td py:content="foo['count']">42</td>
      <td py:content="foo['rlcount']">41</td>
      <td py:content="foo['percent']">86.4</td>
    </tr>
  </div>
</table>

  <?php
  include("../Templates/clsfooter.php");
  ?>

</body>
</html>

