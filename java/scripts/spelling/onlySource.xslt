<xsl:stylesheet version="1.0"
	xmlns:x="urn:oasis:names:tc:xliff:document:1.1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text"/>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>

	<xsl:template match="x:source">
		<xsl:value-of select="text()"/>
		<xsl:text> </xsl:text>
	</xsl:template>

</xsl:stylesheet>
