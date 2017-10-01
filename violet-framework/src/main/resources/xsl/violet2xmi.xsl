<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xmi="http://schema.omg.org/spec/XMI/2.5.1"
    xmlns:uml = "http://schema.omg.org/spec/UML/2.5"
	xmlns:violet = "http://www.violet.org/"
>
	
	<xsl:output encoding="UTF-8" method="xml" indent="yes" />
    
    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- Root node                                                                               -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
	<xsl:variable name="root" select="/ClassDiagramGraph" />
	
    <xsl:template match="/">					
		<xmi:XMI version="2.5.1">
            <xmi:documentation>
                <xsl:attribute name="exporter">Violet Plugin</xsl:attribute>
                <xsl:attribute name="exporterVersion">0.1 revised on $Date: 2008/08/26 22:08:19 $</xsl:attribute>
            </xmi:documentation>
            <uml:Model>
                <xsl:attribute name="xmi:id"><xsl:value-of select = "generate-id()" /></xsl:attribute>
                <xsl:attribute name="xmi:type">uml:Model</xsl:attribute>
                <xsl:attribute name="name">ModelName</xsl:attribute>
                <xsl:apply-templates select="/ClassDiagramGraph" />
            </uml:Model>
		</xmi:XMI>
	</xsl:template>
    
    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- ClassDiagram definition                                                                 -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
    <xsl:template match="/ClassDiagramGraph">
        <xsl:apply-templates select="nodes/PackageNode" />
		<xsl:apply-templates select="nodes/InterfaceNode" />
		<xsl:apply-templates select="nodes/ClassNode" />
		<xsl:apply-templates select="edges/InterfaceInheritanceEdge" />
    </xsl:template>
    
	<!-- Package definition                                                                      -->
    <xsl:template match="PackageNode">
		<xsl:call-template name="applyPackagedElement">
			<xsl:with-param name="type">uml:Package</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Class definition                                                                        -->
    <xsl:template match="ClassNode">
		<xsl:call-template name="applyPackagedElement">
			<xsl:with-param name="type">uml:Class</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Interface definition                                                                    -->
    <xsl:template match="InterfaceNode">
		<xsl:call-template name="applyPackagedElement">
			<xsl:with-param name="type">uml:Interface</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Interface realisations                                                                  -->
    <xsl:template match="InterfaceInheritanceEdge">
		<xsl:call-template name="applyRealization" />
	</xsl:template>
	
	
	<!-- Violet attribute definition                                                             -->
    <xsl:template match="attributes">
		<xsl:call-template name="applyMethodOrAttribute">
			<xsl:with-param name="template_name">applyOwnedAttribute</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- Violet methods definition                                                             -->
    <xsl:template match="methods">
		<xsl:call-template name="applyMethodOrAttribute">
			<xsl:with-param name="template_name">applyOwnedOperation</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- apply method or attribute template -->
	<xsl:template name="applyMethodOrAttribute">
		<xsl:param name="template_name" />
		<xsl:variable name="text" select="text" />
	
		<xsl:choose>
			<xsl:when test="ancestor::PackageNode" >
				<xsl:analyze-string select="ancestor::PackageNode/name/text" regex="([\w\\\.]+)(:.*|\(.*)?$">
					<xsl:matching-substring>
						<!-- apply ownedAttribute for each line -->
						<xsl:for-each select="tokenize($text,'\r?\n')">
							<xsl:call-template name="callMethodOrAttributeTemplate">
								<xsl:with-param name="template_name" select="$template_name" />
								<xsl:with-param name="line"><xsl:sequence select="."/></xsl:with-param>
								<xsl:with-param name="package_name" select="regex-group(1)" />
							</xsl:call-template>
						</xsl:for-each>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:otherwise>
				<!-- apply ownedAttribute for each line -->
				<xsl:for-each select="tokenize($text,'\r?\n')">
					<xsl:call-template name="callMethodOrAttributeTemplate">
						<xsl:with-param name="template_name" select="$template_name" />
						<xsl:with-param name="line"><xsl:sequence select="."/></xsl:with-param>
						<xsl:with-param name="package_name"></xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
        </xsl:choose>
	</xsl:template>
	
	<!-- call method or attribute template -->
	<xsl:template name="callMethodOrAttributeTemplate">
		<xsl:param name="template_name" />
		<xsl:param name="line" />
		<xsl:param name="package_name" />
		
		<xsl:choose>
			<xsl:when test="$template_name = 'applyOwnedAttribute'" >
				<xsl:call-template name="applyOwnedAttribute">
					<xsl:with-param name="line"  select="$line" />
					<xsl:with-param name="package_name" select="$package_name" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$template_name = 'applyOwnedOperation'" >
				<xsl:call-template name="applyOwnedOperation">
					<xsl:with-param name="line"  select="$line" />
					<xsl:with-param name="package_name" select="$package_name" />
				</xsl:call-template>
			</xsl:when>
        </xsl:choose>
	</xsl:template>
	
	<!-- search for class edges/assoziations -->
	<xsl:template name="applyGeneralization">
		<xsl:param name="id" />
		
		<xsl:choose>
			<xsl:when test="count($root/edges/InheritanceEdge[startNode/@reference = $id]) &gt; 0">
				<generalization>
					<xsl:attribute name="xmi:id"><xsl:value-of select="$root/edges/InheritanceEdge[startNode/@reference = $id]/@id" /></xsl:attribute>
					<xsl:attribute name="xmi:type">uml:Generalization</xsl:attribute>
					<xsl:attribute name="general"><xsl:value-of select="$root/edges/InheritanceEdge[startNode/@reference = $id]/endNode/@reference" /></xsl:attribute>
				</generalization>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- search for class or interface comments -->
	<xsl:template name="applyNotes">
		<xsl:param name="id" />
		
		<xsl:choose>
			<xsl:when test="count($root/edges/NoteEdge[endNode/@reference = $id]) &gt; 0">
				<xsl:variable name="edge" select="$root/edges/NoteEdge[endNode/@reference = $id]" />
				<ownedComment>
					<xsl:attribute name="xmi:id"><xsl:value-of select="$edge/@id" /></xsl:attribute>
					<xsl:attribute name="xmi:type">uml:Comment</xsl:attribute>
					<xsl:attribute name="body"><xsl:value-of select="$root/nodes/NoteNode[@id = $edge/startNode/@reference]/text/text" /></xsl:attribute>
				</ownedComment>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- apply Realization -->
	<xsl:template name="applyRealization">
		<packagedElement>
			<xsl:attribute name="xmi:type">uml:Realization</xsl:attribute>
			<xsl:attribute name="xmi:id"><xsl:value-of select="@id" /></xsl:attribute>
			<xsl:attribute name="client"><xsl:value-of select="startNode/@reference" /></xsl:attribute>
			<xsl:attribute name="supplier"><xsl:value-of select="endNode/@reference" /></xsl:attribute>
			<xsl:attribute name="realizingClassifier"><xsl:value-of select="endNode/@reference" /></xsl:attribute>
		</packagedElement>
	</xsl:template>
	
	
	<!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- UML definition                                                                          -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
	
	<xsl:template name="applyPackagedElement">
		<xsl:param name="type" />
		<packagedElement>
			<xsl:attribute name="xmi:type"><xsl:value-of select="$type" /></xsl:attribute>
			<xsl:attribute name="xmi:id"><xsl:value-of select="@id" /></xsl:attribute>
			<xsl:call-template name="setName"><xsl:with-param name="name" select="name/text" /></xsl:call-template>
			<xsl:call-template name="setVisibility"><xsl:with-param name="name" select="name/text" /></xsl:call-template>
			<xsl:call-template name="setAbstract"><xsl:with-param name="name" select="name/text" /></xsl:call-template>
			
			<!-- apply subelements -->
			<xsl:choose >
				<xsl:when test="contains($type,'Package')" >
					<xsl:apply-templates select="children/InterfaceNode" />
					<xsl:apply-templates select="children/ClassNode" />
				</xsl:when>
				<xsl:when test="contains($type,'Interface')" >
					<xsl:call-template name="applyGeneralization"><xsl:with-param name="id" select="@id" /></xsl:call-template>
					<xsl:call-template name="applyNotes"><xsl:with-param name="id" select="@id" /></xsl:call-template>
					<xsl:apply-templates select="attributes" />
					<xsl:apply-templates select="methods" />
				</xsl:when>
				<xsl:when test="contains($type,'Class')" >
					<xsl:call-template name="applyGeneralization"><xsl:with-param name="id" select="@id" /></xsl:call-template>
					<xsl:call-template name="applyNotes"><xsl:with-param name="id" select="@id" /></xsl:call-template>
					<xsl:apply-templates select="attributes" />
					<xsl:apply-templates select="methods" />
				</xsl:when>
				<xsl:otherwise />
        </xsl:choose> 
		</packagedElement>
	</xsl:template>
	
	<!-- process attributes -->
	<xsl:template name="applyOwnedAttribute">
		<xsl:param name="line" />
		<xsl:param name="package_name" />
		
		<xsl:if test="not($line = '')">
			<ownedAttribute>
				<xsl:attribute name="xmi:type">uml:Property</xsl:attribute>
				<xsl:attribute name="xmi:id"><xsl:value-of select="generate-id($line)" /></xsl:attribute>
				<xsl:call-template name="setName"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="setVisibility"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="setStatic"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="setType">
					<xsl:with-param name="name" select="$line" />
					<xsl:with-param name="package_name" select="$package_name" />
				</xsl:call-template>
			</ownedAttribute>
		</xsl:if>
	</xsl:template>
	
	<!-- process operations -->
	<xsl:template name="applyOwnedOperation">
		<xsl:param name="line" />
		<xsl:param name="package_name" />
		
		<xsl:if test="not($line = '')">
			<ownedOperation>
				<xsl:attribute name="xmi:type">uml:Operation</xsl:attribute>
				<xsl:attribute name="xmi:id"><xsl:value-of select="generate-id($line)" /></xsl:attribute>
				<xsl:call-template name="setName"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="setVisibility"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="setAbstract"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="setStatic"><xsl:with-param name="name" select="$line" /></xsl:call-template>
				<xsl:call-template name="applyParameter">
					<xsl:with-param name="line" select="$line" />
					<xsl:with-param name="package_name" select="$package_name" />
				</xsl:call-template>
			</ownedOperation>
		</xsl:if>
	</xsl:template>
	
	<!-- process operation parameter (incl. return value) -->
	<xsl:template name="applyParameter">
		<xsl:param name="line" />
		<xsl:param name="package_name" />
		
		<xsl:analyze-string select="$line" regex="\(([^\)]+)?\)(: ?.*)?$">
			<xsl:matching-substring>
				<xsl:call-template name="applyOwnedParameter">
					<xsl:with-param name="id" select="concat('return_', generate-id($line))"/>
					<xsl:with-param name="line" select="concat('return', regex-group(2))" />
					<xsl:with-param name="package_name" select="$package_name" />
				</xsl:call-template>
				<xsl:for-each select="tokenize(regex-group(1),', ?')">
					<xsl:call-template name="applyOwnedParameter">
						<xsl:with-param name="id" select="concat(substring-before(., ':'), '_', generate-id($line))"/>
						<xsl:with-param name="line"><xsl:sequence select="."/></xsl:with-param>
						<xsl:with-param name="package_name" select="$package_name" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- apply method parameter -->
	<xsl:template name="applyOwnedParameter">
		<xsl:param name="id" />
		<xsl:param name="line" />
		<xsl:param name="package_name" />
		
		<ownedParameter>
			<xsl:call-template name="setName"><xsl:with-param name="name" select="$line" /></xsl:call-template>
			<!-- TODO: Support also direction inout and out -->
			<xsl:attribute name="direction">
				<xsl:choose>
					<xsl:when test="contains($line,'return')" >return</xsl:when>
					<xsl:otherwise>in</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="xmi:id"><xsl:value-of select="$id" /></xsl:attribute>
			<xsl:call-template name="setType">
				<xsl:with-param name="name" select="$line" />
				<xsl:with-param name="package_name" select="$package_name" />
			</xsl:call-template>
		</ownedParameter>
	</xsl:template>
	
	<!-- set ownedAttribute or ownedOperation type, from given violet name !-->
	<xsl:template name="setType">
		<xsl:param name="name" />
		<xsl:param name="package_name" />
		
		<xsl:analyze-string select="$name" regex=": ?([\w\\\.]+)$">
			<xsl:matching-substring>
				<type>
					<!-- support primitive types -->
					<xsl:choose>
						<xsl:when test="regex-group(1) = 'boolean'">
							<xsl:attribute name="xmi:type">uml:PrimitiveType</xsl:attribute>
							<xsl:attribute name="href">http://www.omg.org/spec/UML/20110701/PrimitiveTypes.xmi#Boolean</xsl:attribute>
						</xsl:when>
						<xsl:when test="regex-group(1) = 'integer'">
							<xsl:attribute name="xmi:type">uml:PrimitiveType</xsl:attribute>
							<xsl:attribute name="href">http://www.omg.org/spec/UML/20110701/PrimitiveTypes.xmi#Integer</xsl:attribute>
						</xsl:when>
						<xsl:when test="regex-group(1) = 'real'">
							<xsl:attribute name="xmi:type">uml:PrimitiveType</xsl:attribute>
							<xsl:attribute name="href">http://www.omg.org/spec/UML/20110701/PrimitiveTypes.xmi#Real</xsl:attribute>
						</xsl:when>
						<xsl:when test="regex-group(1) = 'string'">
							<xsl:attribute name="xmi:type">uml:PrimitiveType</xsl:attribute>
							<xsl:attribute name="href">http://www.omg.org/spec/UML/20110701/PrimitiveTypes.xmi#String</xsl:attribute>
						</xsl:when>
						<xsl:when test="regex-group(1) = 'unlimitednatural'">
							<xsl:attribute name="xmi:type">uml:PrimitiveType</xsl:attribute>
							<xsl:attribute name="href">http://www.omg.org/spec/UML/20110701/PrimitiveTypes.xmi#UnlimitedNatural</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="xmi:type"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
							<xsl:call-template name="setReference">
								<xsl:with-param name="name" select="regex-group(1)" />
								<xsl:with-param name="package_name" select="$package_name" />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</type>
			</xsl:matching-substring>
		</xsl:analyze-string>
		
	</xsl:template>
	
	<!-- set reference for given name if exists -->
	<xsl:template name="setReference">
		<xsl:param name="name" />
		<xsl:param name="package_name" />
		
		<xsl:choose>
			<!-- 
				check if $name is a package name before $package_name is tested, we also want to 
			    refer packages if we are in a packge 
			-->
			<xsl:when test="contains($name, '.') or contains($name, '\')" >
				<xsl:call-template name="setReferenceAttribute">
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="node" select="$root/nodes" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$package_name != '' and count($root/nodes/PackageNode[contains(name/text, $package_name)]/children/ClassNode[contains(name/text, $name)])">
				<xsl:call-template name="setReferenceAttribute">
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="node" select="$root/nodes/PackageNode[contains(name/text, $package_name)]/children" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="setReferenceAttribute">
					<xsl:with-param name="name" select="$name" />
					<xsl:with-param name="node" select="$root/nodes" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- set real idref attribute by given name and node -->
	<xsl:template name="setReferenceAttribute">
		<xsl:param name="node" />
		<xsl:param name="name" />
		<!-- TODO: This template does not support sub packages -->
		<xsl:choose>
			<xsl:when test="contains($name, '.') or contains($name, '\')" >
				<xsl:analyze-string select="$name" regex="(.*)[\\\.](.*)$">
					<xsl:matching-substring>
						<xsl:if test="count($node/PackageNode[contains(name/text, regex-group(1))]) &gt; 0">
							<xsl:call-template name="setReferenceAttribute">
								<xsl:with-param name="name" select="regex-group(2)" />
								<xsl:with-param name="node" select="$node/PackageNode[contains(name/text, regex-group(1))]/children" />
							</xsl:call-template>
						</xsl:if>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:when test="count($node/ClassNode[contains(name/text, $name)]) &gt; 0">
				<xsl:attribute name="xmi:type">uml:Class</xsl:attribute>
				<xsl:attribute name="xmi:idref">
					<xsl:value-of select="$node/ClassNode[contains(name/text, $name)]/@id" />
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="count($node/InterfaceNode[contains(name/text, $name)]) &gt; 0">
				<xsl:attribute name="xmi:type">uml:Class</xsl:attribute>
				<xsl:attribute name="xmi:idref">
					<xsl:value-of select="$node/InterfaceNode[contains(name/text, $name)]/@id" />
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- set cleaned name attribute, from given violet name !-->
	<xsl:template name="setName">
		<xsl:param name="name" />
		<xsl:analyze-string select="$name" regex="([\w\\\.]+)(:.*|\(.*)?$">
			<xsl:matching-substring>
				<xsl:attribute name="name"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- set visibility attribute, from given name !-->
	<xsl:template name="setVisibility">
		<xsl:param name="name" />
		<xsl:choose >
        	<xsl:when test="contains($name,'private')" >
            	<xsl:attribute name="visibility">private</xsl:attribute>
            </xsl:when>
			<xsl:when test="contains($name,'protected')" >
            	<xsl:attribute name="visibility">protected</xsl:attribute>
            </xsl:when>
			<xsl:when test="contains($name,'package')" >
            	<xsl:attribute name="visibility">package</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
				<xsl:attribute name="visibility">public</xsl:attribute>
			</xsl:otherwise>
        </xsl:choose> 
	</xsl:template>
	
	<!-- set isAbstract attribute, if name contains <<abstract>> !-->
	<xsl:template name="setAbstract">
		<xsl:param name="name" />
		<xsl:choose >
        	<xsl:when test = "contains($name,'&lt;&lt;abstract&gt;&gt;')" >
            	<xsl:attribute name="isAbstract">true</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
				<xsl:attribute name="isAbstract">false</xsl:attribute>
			</xsl:otherwise>
        </xsl:choose> 
	</xsl:template>
	
	<!-- set isStatic attribute, if name contains <<static>> !-->
	<xsl:template name="setStatic">
		<xsl:param name="name" />
		<xsl:choose >
        	<xsl:when test = "contains($name,'&lt;&lt;static&gt;&gt;')" >
            	<xsl:attribute name="isStatic">true</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
				<xsl:attribute name="isStatic">false</xsl:attribute>
			</xsl:otherwise>
        </xsl:choose> 
	</xsl:template>
	
</xsl:stylesheet>
