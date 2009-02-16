<?xml version="1.0" ?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:value-of select="/params/param/value/struct/member[name/text()='system_id']/value"/>
    <xsl:text>
  </xsl:text>

  </xsl:template>

</xsl:stylesheet>
