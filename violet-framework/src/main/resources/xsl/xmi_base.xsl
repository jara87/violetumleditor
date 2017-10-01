<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nl "&#xa;">
]>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xmi="http://schema.omg.org/spec/XMI/2.5.1"
    xmlns:uml = "http://schema.omg.org/spec/UML/2.5"
>
	<!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- XMI Base file                                                                           -->
	<!--                                                                                         -->
    <!-- This file is the basic code generation file. It converts XMI 2.5 (with UML 2.5) files   -->
	<!-- to code.                                                                                -->
	<!-- To do this, it collects the information of given xmi file and call xsl templates with   -->
	<!-- parameter to generate the code. You only have to include this document in your xslt     -->
	<!-- file and define the called xsl templates with your language specific code generation.   -->
    <!--                                                                                         -->
    <!-- To include this file, please add the xsl:include tag at hte begining of your            -->
	<!-- stylesheet:                                                                             -->
    <!--                                                                                         -->
    <!--     <xsl:include href="xmi_base.xsl" />                                                 -->
    <!--                                                                                         -->
	<!-- Now you have to define following xsl templates for code generation:                     -->
	<!--                                                                                         -->
	<!--                                                                                         
			<xsl:template name="file_name">
				<xsl:param name="path" />
				<xsl:param name="name" />
			</xsl:template>
	
			<xsl:template name="file_header">
				<xsl:param name="class_name"   />
				<xsl:param name="description"  />
				<xsl:param name="project_name" />
				<xsl:param name="author"       />
				<xsl:param name="copyright"    />
				<xsl:param name="url"          />
			</xsl:template>
			
			<xsl:template name="file_footer">
			</xsl:template>
			
			<xsl:template name="package_definition">
				<xsl:param name="package_name" />
            </xsl:template>
			
			<xsl:template name="include_definition">
				<xsl:param name="classes" />
			</xsl:template>
			
			<xsl:template name="class_header">
				<xsl:param name="class_name"  />
				<xsl:param name="description" />
        	</xsl:template>
    
			<xsl:template name="class_definition">
				<xsl:param name="class_name" />
				<xsl:param name="type"       />
				<xsl:param name="abstract"   />
				<xsl:param name="extends"    />
				<xsl:param name="implements" />
			</xsl:template>
    
			<xsl:template name="class_footer">
			</xsl:template>
	
			<xsl:template name="attribute_definition">
				<xsl:param name="name"        />
				<xsl:param name="type"        />
				<xsl:param name="description" />
				<xsl:param name="visibility"  />
				<xsl:param name="static"      />
			</xsl:template>
	
			<xsl:template name="method_definition">
				<xsl:param name="name"        />
				<xsl:param name="return"      />
				<xsl:param name="params"      />
				<xsl:param name="abstract"    />
				<xsl:param name="static"      />
				<xsl:param name="description" />
				<xsl:param name="visibility"  />
				<xsl:param name="type"        />
			</xsl:template>
	-->
    <!-- *************************************************************************************** -->
    

    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- Global variable definition                                                              -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
	<xsl:output encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
    <xsl:variable name="root" select="/xmi:XMI/uml:Model" />
	<xsl:variable name="nl" select="'&nl;'"/>
	
    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- Parameter definition                                                                    -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
    <xsl:param name="path"         >.</xsl:param>
    <xsl:param name="project_name" >${project.name}</xsl:param>
    <xsl:param name="author"       >${author}</xsl:param>
    <xsl:param name="copyright"    >${copyright}</xsl:param>
    <xsl:param name="url"          >${url}</xsl:param>
    <xsl:param name="main_package" />
    
    
    <!-- *************************************************************************************** -->
	<!--                                                                                         -->
    <!-- XMI definition                                                                      -->
    <!--                                                                                         -->
    <!-- *************************************************************************************** -->
    
    <xsl:template match="/xmi:XMI/uml:Model">	
        <xsl:for-each select=".//packagedElement[@xmi:type = 'uml:Class' or @xmi:type = 'uml:Interface']">
            <xsl:call-template name="createFile">
                <xsl:with-param name="element" select="." />
            </xsl:call-template>
        </xsl:for-each>
	</xsl:template>
	
	<!-- 
		Matching templates 
	-->
	<!-- Attribute match -->
	<xsl:template match="ownedAttribute">
        <xsl:call-template name="createAttribute">
			<xsl:with-param name="element" select="." />
		</xsl:call-template>
	</xsl:template>
    
	<!-- Operation match -->
	<xsl:template match="ownedOperation">
		<xsl:call-template name="createMethod">
			<xsl:with-param name="element" select="." />
		</xsl:call-template>
	</xsl:template>
	
	<!-- 
		Named templates 
	-->
	
	<!-- create file from given packagedElement with given path -->
	<xsl:template name="createFile">
		<xsl:param name="element" />
        
        <xsl:variable name="package">
            <xsl:call-template name="createPackagePath">
                <xsl:with-param name="element" select="$element" />
            </xsl:call-template>
        </xsl:variable>
		
		<xsl:variable name="file_name">
			<xsl:if test="not($path = '')"><xsl:value-of select="$path" />/</xsl:if>
            <xsl:call-template name="file_name">
				<xsl:with-param name="path" select="$package"    />
				<xsl:with-param name="name" select="$element/@name" />
			</xsl:call-template>        
        </xsl:variable>
        
		<xsl:variable name="description">
			<xsl:if test="count($element/ownedComment) &gt; 0">
				<xsl:value-of select="$element/ownedComment/@body" />
			</xsl:if>
        </xsl:variable>
		
        <!--xsl:message>Generate file: <xsl:value-of select="$file_name" /></xsl:message-->
        
		<xsl:result-document href="{$file_name}" method="text">
			<xsl:call-template name="file_header">
				<xsl:with-param name="class_name"   select="$element/@name"/>
				<xsl:with-param name="project_name" select="$project_name"/>
				<xsl:with-param name="author"       select="$author"/>
				<xsl:with-param name="copyright"    select="$copyright"/>
				<xsl:with-param name="url"          select="$url"/>
				<xsl:with-param name="description"  select="$description" />
			</xsl:call-template>
			
			<xsl:call-template name="package_definition">
				<xsl:with-param name="package_name" select="$package" />
			</xsl:call-template>
			
			<xsl:call-template name="include_definition">
				<xsl:with-param name="classes">
					<xsl:call-template name="getIncludes">
						<xsl:with-param name="own_class" select="$element/@name" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="createClass">
				<xsl:with-param name="element"      select="$element" />
			</xsl:call-template>
			
			<xsl:call-template name="file_footer" />
		</xsl:result-document>
	</xsl:template>
	
	<!-- search for all other includes -->
	<xsl:template name="getIncludes">
		<xsl:param name="own_class" />
		
		<xsl:for-each select="$root//packagedElement[@name ne $own_class and @xmi:type ne 'uml:Package']">
            <xsl:call-template name="createPackagePath">
                <xsl:with-param name="element" select="." />
            </xsl:call-template>
			<xsl:value-of select="./@name" />
			<xsl:if test="position() != last()">, </xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- create path for given class or interface element -->
	<xsl:template name="createPackagePath">
		<xsl:param name="element" />
		
		<xsl:choose>
            <xsl:when test="$element/parent::packagedElement[@xmi:type eq 'uml:Package']">
                <xsl:call-template name="createPackagePath">
                    <xsl:with-param name="element" select="$element/parent::packagedElement" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not($main_package = '')"><xsl:value-of select="$main_package" />/</xsl:when>
        </xsl:choose>
        
        <xsl:if test="$element/@xmi:type eq 'uml:Package'"><xsl:value-of select="replace($element/@name, '\.|\\', '/')" />/</xsl:if>
	</xsl:template>
	
    <!-- create class template -->
    <xsl:template name="createClass">
        <xsl:param name="element" />
        
		<!-- get description -->
		<xsl:variable name="description">
			<xsl:if test="count($element/ownedComment) &gt; 0">
				<xsl:value-of select="$element/ownedComment/@body" />
			</xsl:if>
        </xsl:variable>
		
        <xsl:call-template name="class_header">
            <xsl:with-param name="class_name"  select="$element/@name" />
            <xsl:with-param name="description" select="$description" />
        </xsl:call-template>
        
        <!-- get generalisation -->
        <xsl:variable name="extends">
            <xsl:if test="count($element/generalization) &gt; 0">
                <xsl:for-each select="$root//packagedElement[@xmi:id = $element/generalization/@general]/@name">
                    <xsl:value-of select="." />
                    <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
            </xsl:if>        
        </xsl:variable>
        
        <!-- get realisation -->
        <xsl:variable name="implements">
            <xsl:if test="count($root/packagedElement[@xmi:type = 'uml:Realization' and @client = $element/@xmi:id]) &gt; 0">
                <xsl:for-each select="$root/packagedElement[@xmi:type = 'uml:Realization' and @client = $element/@xmi:id]/@name">
                    <xsl:sequence select="." />
                    <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
            </xsl:if>        
        </xsl:variable>
		
		<!-- call class definition template -->
        <xsl:call-template name="class_definition">
            <xsl:with-param name="class_name" select="$element/@name" />
            <xsl:with-param name="abstract"   select="$element/@isAbstract" />
            <xsl:with-param name="type">
                <xsl:choose>
                    <xsl:when test="contains($element/@xmi:type, 'Interface')">interface</xsl:when>
                    <xsl:otherwise>class</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="extends"    select="$extends" />
            <xsl:with-param name="implements" select="$implements" />
        </xsl:call-template>
        
        <xsl:apply-templates select="$element/ownedAttribute" />
        <xsl:apply-templates select="$element/ownedOperation" />
        
        <xsl:call-template name="class_footer" />
    </xsl:template>
	
	<!-- create attribute template -->
    <xsl:template name="createAttribute">
		<xsl:param name="element" />
		
		<xsl:variable name="type">
            <xsl:if test="count($element/type) &gt; 0">
				<xsl:call-template name="getType">
					<xsl:with-param name="element" select="$element/type" />
				</xsl:call-template>
            </xsl:if>        
        </xsl:variable>
		
		<!-- call attribute definition template -->
		<xsl:call-template name="attribute_definition">
			<xsl:with-param name="name"       select="$element/@name" />
			<xsl:with-param name="type"       select="$type" />
			<xsl:with-param name="visibility" select="$element/@visibility" />
			<xsl:with-param name="static"     select="$element/@isStatic" />
			<xsl:with-param name="description"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- create method template -->
    <xsl:template name="createMethod">
		<xsl:param name="element" />
		
		<xsl:variable name="type">
            <xsl:choose>
				<xsl:when test="$element/../@xmi:type eq 'uml:Interface'">interface</xsl:when>
				<xsl:otherwise>class</xsl:otherwise>
			</xsl:choose>  
        </xsl:variable>
		
		<xsl:variable name="return">
            <xsl:if test="count($element/ownedParameter[@direction = 'return']/type) &gt; 0" >
				<xsl:call-template name="getType">
					<xsl:with-param name="element" select="$element/ownedParameter[@direction = 'return']/type" />
				</xsl:call-template>
			</xsl:if>
        </xsl:variable>
		
		<xsl:variable name="params">
			<!-- TODO: Support also out and inout parameter -->
            <xsl:if test="count($element/ownedParameter[@direction = 'in']) &gt; 0" >
				<xsl:for-each select="$element/ownedParameter[@direction = 'in']">
                    <xsl:value-of select="./@name" />
					<xsl:if test="count(./type) &gt; 0">:<xsl:call-template name="getType">
							<xsl:with-param name="element" select="./type" />
						</xsl:call-template>
					</xsl:if>
                    <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
			</xsl:if>
        </xsl:variable>
		
		<!-- call method definition template -->
		<xsl:call-template name="method_definition">
			<xsl:with-param name="name"       select="$element/@name" />
			<xsl:with-param name="visibility" select="$element/@visibility" />
			<xsl:with-param name="abstract"   select="$element/@isAbstract" />
			<xsl:with-param name="static"     select="$element/@isStatic" />
			<xsl:with-param name="type"       select="$type" />
			<xsl:with-param name="return"     select="$return" />
			<xsl:with-param name="params"     select="$params" />
        	<xsl:with-param name="description"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- get aprameter type template -->
	<xsl:template name="getType">
		<xsl:param name="element" />
		<xsl:choose>
			<xsl:when test="$element/@xmi:type eq 'uml:Class'">
				<xsl:value-of select="$root//packagedElement[@xmi:id = $element/@xmi:idref]/@name" />
			</xsl:when>
			<xsl:when test="$element/@xmi:type eq 'uml:PrimitiveType'">
				<xsl:value-of select="replace($element/@href, '.*#(.*)','$1')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$element/@xmi:type" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>