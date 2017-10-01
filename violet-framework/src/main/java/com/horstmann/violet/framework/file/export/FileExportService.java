/*
 Violet - A program for editing UML diagrams.

 Copyright (C) 2007 Cay S. Horstmann (http://horstmann.com)
 Alexandre de Pellegrin (http://alexdp.free.fr);

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

package com.horstmann.violet.framework.file.export;

import com.horstmann.violet.framework.file.persistence.XStreamBasedPersistenceService;
import com.horstmann.violet.framework.injection.resources.ResourceBundleConstant;
import com.horstmann.violet.framework.util.ClipboardPipe;
import com.horstmann.violet.framework.util.PDFGraphics2DStringWriter;
import com.horstmann.violet.product.diagram.abstracts.IGraph;
import org.freehep.graphicsbase.util.UserProperties;
import org.freehep.graphicsio.pdf.PDFGraphics2D;

import java.awt.*;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.Calendar;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.ResourceBundle;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public class FileExportService
{
    /**
     * Return the image correspondiojng to the graph
     *
     * @param graph
     * @return bufferedImage. To convert it into an image, use the syntax :
     * Toolkit.getDefaultToolkit().createImage(bufferedImage.getSource());
     * @author Alexandre de Pellegrin
     */
    public static BufferedImage getImage(IGraph graph)
    {
        Rectangle2D bounds = graph.getClipBounds();

        BufferedImage image = new BufferedImage((int) bounds.getWidth() + 1, (int) bounds.getHeight() + 1,
                BufferedImage.TYPE_INT_RGB);
        Graphics2D g2 = (Graphics2D) image.getGraphics();

        renderIGraphToGraphics2D(graph, g2);

        return image;
    }

    /**
     * Export graph to clipboard (Do not merge with exportToClipBoard(). Used in Eclipse plugin)
     *
     * @param graph
     * @author Alexandre de Pellegrin
     */
    public static void exportToclipBoard(IGraph graph)
    {
        BufferedImage bImage = getImage(graph);
        ClipboardPipe pipe = new ClipboardPipe(bImage);
        Toolkit.getDefaultToolkit().getSystemClipboard().setContents(pipe, null);
    }

    /**
     * Export graph to PDF file
     *
     * @param graph
     * @param out   output stream to file
     * @author Michał Leśniak
     */
    public static void exportToPdf(IGraph graph, OutputStream out)
    {
        Rectangle2D bounds = graph.getClipBounds();

        UserProperties p = new UserProperties();
        p.setProperty(PDFGraphics2D.PAGE_SIZE, PDFGraphics2D.CUSTOM_PAGE_SIZE);
        p.setProperty(PDFGraphics2D.CUSTOM_PAGE_SIZE, new Dimension((int) bounds.getWidth(), (int) bounds.getHeight()));
        p.setProperty(PDFGraphics2D.VERSION, PDFGraphics2D.VERSION6);
        p.setProperty(PDFGraphics2D.FIT_TO_PAGE, "false");
        p.setProperty(PDFGraphics2D.EMBED_FONTS, "true");

        PDFGraphics2D g = new PDFGraphics2DStringWriter(out, bounds.getBounds().getSize());
        g.setProperties(p);
        g.startExport();

        renderIGraphToGraphics2D(graph, g);

        g.endExport();
    }

    private static Graphics2D renderIGraphToGraphics2D(IGraph graph, Graphics2D g2)
    {
        Rectangle2D bounds = graph.getClipBounds();

        g2.translate(-bounds.getX(), -bounds.getY());
        g2.setColor(Color.WHITE);
        g2.fill(new Rectangle2D.Double(bounds.getX(), bounds.getY(), bounds.getWidth() + 1, bounds.getHeight() + 1));

        g2.setColor(Color.BLACK);
        g2.setBackground(Color.WHITE);

        graph.draw(g2);

        return g2;
    }

    /**
     * Auteur : a.depellegrin<br>
     * Definition : Exports class diagram graph to xmi <br>
     *
     * @param graph to export
     * @param out   to write result
     */
    public static void exportToXMI(IGraph graph, OutputStream out)
    {
		if (!graph.isXMIExportable()) {
			// Only exports supported diagrams
			return;
		}
 
		// Convert graph to Violet's XML
		ByteArrayOutputStream graphOut = new ByteArrayOutputStream();
		XStreamBasedPersistenceService xStreamService = new XStreamBasedPersistenceService();
		xStreamService.write(graph, graphOut);
		ByteArrayInputStream graphIn = new ByteArrayInputStream(graphOut.toByteArray());
		 
		// transform to XMI
		convertStreamWithXSL("files.xsl.violet2xmi", graphIn, out, null);
		 
		// close streams
		try {
			graphOut.close();
			graphIn.close();
		} catch (IOException e) {
			// Do nothing...
		}
    }
    
    /**
     * Exports given graph to PHP with given config.
     * @param graph
     * @param config
     */
    public static void exportToPHP(IGraph graph, Properties config) {
    	exportToCode("files.xsl.xmi2php", graph, config);
    }
    
    /**
     * Exports given graph to Java with given config.
     * @param graph
     * @param config
     */
    public static void exportToJava(IGraph graph, Properties config) {
    	exportToCode("files.xsl.xmi2java", graph, config);
    }
    
    /**
     * Exports given graph with given resource type with given config.
     * The configuration is based on the xmi_base.xsl file's parameter set.
     * Known properties are:
     *   path         = base output path
     *   project_name = Project Name
     *   author       = Code Author
     *   copyright    = Copyright year
     *   url          = Project URL
     *   main_package = Main Package name, if any
     * 
     * For more information, please read xmi_base.xsl file.
     * 
     * @param xslResourceType
     * @param graph
     * @param config
     */
    public static void exportToCode(String xslResourceType, IGraph graph, Properties config) {
    	if (!graph.isXMIExportable()) {
			// Only exports supported diagrams
			return;
		}
    	
    	// set defaults
    	if (!config.containsKey("copyright")) {
    		config.setProperty("copyright", Integer.toString(Calendar.getInstance().get(Calendar.YEAR)));
    	}
    	
    	// Convert graph to XMI
		ByteArrayOutputStream graphOut = new ByteArrayOutputStream();
		exportToXMI(graph, graphOut);
		ByteArrayInputStream xmiStream = new ByteArrayInputStream(graphOut.toByteArray());
		
		// temporary in memory stream. The files will be generated by xslt
		ByteArrayOutputStream tmp_stream = new ByteArrayOutputStream();
		// transform to PHP
		convertStreamWithXSL(xslResourceType, xmiStream, tmp_stream, config);
		
		// close streams
		try {
			graphOut.close();
			xmiStream.close();
			tmp_stream.close();
		} catch (IOException e) {
			// Do nothing...
		}
    }
    
    /**
     * Convert input stream with given xsl resource to output stream.
     * 
     * @param xslResourceType
     * @param in
     * @param out
     */
    protected static void convertStreamWithXSL(String xslResourceType, InputStream in, OutputStream out, Properties config) {
    	try
        {
    		// Gets xsl file
			ResourceBundle fileResourceBundle = ResourceBundle.getBundle(
				ResourceBundleConstant.XSL_FILES, Locale.getDefault()
			);
			URL xsl = FileExportService.class.getResource(
				fileResourceBundle.getString(xslResourceType)
			);
			
			// XSL transform
			InputStream xslStream      = xsl.openStream();
			TransformerFactory factory = new net.sf.saxon.TransformerFactoryImpl();
			
			// resolve xsl:include links correct from class path
			factory.setURIResolver(new URIResolver() {
				@Override
				public Source resolve(String href, String base) throws TransformerException {
					return new StreamSource(
						FileExportService.class.getClassLoader().getResourceAsStream(href)
					);
				}
			});
			
			Transformer transformer = factory.newTransformer(new StreamSource(xslStream));
			
			if (config != null && !config.isEmpty()) {
				// Check and "beautify" path property
				if (config.containsKey("path")) {
					config.setProperty(
						"path", 
						config.getProperty("path").replace("\\", "/")
					);
				}
				
				for (Map.Entry<Object, Object> e : config.entrySet()) {
					System.out.println("Add " + e.getKey() + " with " + e.getValue());
					transformer.setParameter((String) e.getKey(), (String) e.getValue());
				}
			}
			
			transformer.transform(new StreamSource(in), new StreamResult(out));
 
			// Closes unused streams
			xslStream.close();
        }
        catch (Exception e)
        {
       	 	throw new RuntimeException(e);
        }
    }
}
